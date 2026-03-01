class ChatMessage < ApplicationRecord
  belongs_to :cohort
  belongs_to :user

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit -> {
    message = ChatMessage.includes(user: { avatar_attachment: :blob }).find(id)
    broadcast_append_to(
      cohort,
      :chat,
      target: "chat_messages",
      partial: "chat_messages/chat_message",
      locals: { chat_message: message }
    )
  }
end
