class ChatMessage < ApplicationRecord
  belongs_to :cohort
  belongs_to :user

  validates :body, presence: true

  after_create_commit -> {
    broadcast_append_to(
      "cohort_#{cohort_id}_chat",
      target: "chat_messages",
      partial: "chat_messages/chat_message",
      locals: { chat_message: self }
    )
  }
end
