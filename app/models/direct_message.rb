class DirectMessage < ApplicationRecord
  include Mentionable
  include UnreadBadgeBroadcaster
  include PushNotifiable

  belongs_to :conversation
  belongs_to :sender, class_name: "User", inverse_of: :sent_direct_messages

  encrypts :body

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit :broadcast_all
  after_create_commit :send_push_notifications
  after_create_commit :broadcast_unread_badges

  private

  def broadcast_all
    message = DirectMessage.includes(:conversation, sender: { avatar_attachment: :blob }).find(id)

    broadcast_append_to(
      message.conversation,
      target: "direct_messages",
      partial: "direct_messages/direct_message",
      locals: { direct_message: message }
    )

    message.conversation.participants
      .where.not(id: message.sender_id)
      .where(dm_notifications: true)
      .each do |recipient|
      broadcast_append_to(
        [ recipient, :dm_notifications ],
        target: "dm_notifications",
        partial: "direct_messages/notification",
        locals: { direct_message: message }
      )
    end
  end

  def send_push_notifications
    recipient_ids = conversation.participants.where.not(id: sender_id).pluck(:id)
    push_notify(recipient_ids, title: sender.name, path: "/conversations/#{conversation_id}")
  end

  def broadcast_unread_badges
    recipient_ids = conversation.participants.where.not(id: sender_id).pluck(:id)
    broadcast_unread_badge_to(recipient_ids)
  end
end
