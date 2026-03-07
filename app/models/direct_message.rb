class DirectMessage < ApplicationRecord
  include Mentionable
  include UnreadBadgeBroadcaster

  belongs_to :conversation
  belongs_to :sender, class_name: "User", inverse_of: :sent_direct_messages

  encrypts :body

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit :broadcast_all
  after_create_commit :create_notifications

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

  def create_notifications
    conversation.participants.where.not(id: sender_id).pluck(:id).each do |recipient_id|
      CreateNotificationJob.perform_later(
        user_id: recipient_id,
        actor_id: sender_id,
        event_type: "direct_message",
        title: sender.name,
        body: "Sent you a private message",
        path: "/conversations/#{conversation_id}",
        notifiable_type: "DirectMessage",
        notifiable_id: id,
        group_key: "conversation:#{conversation_id}"
      )
    end
  end
end
