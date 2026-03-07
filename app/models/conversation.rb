class Conversation < ApplicationRecord
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :direct_messages, dependent: :destroy

  def self.between(*users)
    users = users.flatten
    user_ids = users.map(&:id).sort

    # Find conversations that include ALL specified users
    candidate_ids = ConversationParticipant
      .where(user_id: user_ids)
      .group(:conversation_id)
      .having("COUNT(DISTINCT user_id) = ?", users.size)
      .pluck(:conversation_id)

    # Among those, find one with EXACTLY that many participants
    if candidate_ids.any?
      existing = joins(:conversation_participants)
        .where(id: candidate_ids)
        .group("conversations.id")
        .having("COUNT(conversation_participants.id) = ?", users.size)
        .first

      return existing if existing
    end

    transaction do
      conversation = create!
      users.each { |u| conversation.conversation_participants.create!(user: u) }
      conversation
    end
  rescue ActiveRecord::RecordNotUnique
    retries ||= 0
    retry if (retries += 1) < 3
    raise
  end

  def send_message(from:, body:)
    return if body.blank?

    direct_messages.create!(sender: from, body: body)
    touch
  end

  def other_participants(user)
    participants.where.not(id: user.id)
  end

  def display_name(current_user)
    participants.reject { |p| p.id == current_user.id }.map { |p|
      p.discarded? ? "#{p.name} (removed)" : p.name
    }.sort.join(", ")
  end

  def mark_as_read_by(user)
    conversation_participants.find_by(user: user)&.update(last_read_at: Time.current)
    Notification.unread.where(user: user, event_type: "mention", notifiable_type: "DirectMessage")
               .where(notifiable_id: direct_messages.select(:id))
               .update_all(read_at: Time.current)
    Notification.unread.where(user: user, event_type: "direct_message",
                              group_key: "conversation:#{id}")
               .update_all(read_at: Time.current)
  end

  def last_message
    direct_messages.order(created_at: :desc).first
  end

  def unread_count(user)
    participant = conversation_participants.find_by(user: user)
    return 0 unless participant

    messages = direct_messages.where.not(sender: user)
    if participant.last_read_at
      messages.where("created_at > ?", participant.last_read_at).count
    else
      messages.count
    end
  end
end
