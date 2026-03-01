class DirectMessage < ApplicationRecord
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
end
