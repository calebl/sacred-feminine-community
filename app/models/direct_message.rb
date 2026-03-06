class DirectMessage < ApplicationRecord
  include Mentionable

  belongs_to :conversation
  belongs_to :sender, class_name: "User", inverse_of: :sent_direct_messages

  encrypts :body

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit -> {
    message = DirectMessage.includes(sender: { avatar_attachment: :blob }).find(id)
    broadcast_append_to(
      conversation,
      target: "direct_messages",
      partial: "direct_messages/direct_message",
      locals: { direct_message: message }
    )
  }

  after_create_commit :broadcast_notifications

  private

  def broadcast_notifications
    message = DirectMessage.includes(:conversation, sender: { avatar_attachment: :blob }).find(id)
    message.conversation.participants
      .where.not(id: message.sender_id)
      .where(dm_notifications: true)
      .find_each do |recipient|
      broadcast_append_to(
        [ recipient, :dm_notifications ],
        target: "dm_notifications",
        partial: "direct_messages/notification",
        locals: { direct_message: message }
      )
    end
  end
end
