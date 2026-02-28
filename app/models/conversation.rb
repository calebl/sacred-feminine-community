class Conversation < ApplicationRecord
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :direct_messages, dependent: :destroy

  def self.between(user_a, user_b)
    ids_a = ConversationParticipant.where(user: user_a).pluck(:conversation_id)
    ids_b = ConversationParticipant.where(user: user_b).pluck(:conversation_id)
    common = ids_a & ids_b

    if common.any?
      find(common.first)
    else
      transaction do
        conversation = create!
        conversation.conversation_participants.create!(user: user_a)
        conversation.conversation_participants.create!(user: user_b)
        conversation
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # Race condition: another thread created the same conversation. Retry lookup.
    ids_a = ConversationParticipant.where(user: user_a).pluck(:conversation_id)
    ids_b = ConversationParticipant.where(user: user_b).pluck(:conversation_id)
    find((ids_a & ids_b).first)
  end

  def other_participant(user)
    participants.where.not(id: user.id).first
  end

  def last_message
    direct_messages.order(created_at: :desc).first
  end

  def unread_count(user)
    participant = conversation_participants.find_by(user: user)
    return 0 unless participant

    if participant.last_read_at
      direct_messages.where("created_at > ?", participant.last_read_at).count
    else
      direct_messages.count
    end
  end
end
