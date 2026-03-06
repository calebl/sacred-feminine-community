class GroupChatMessage < ApplicationRecord
  include Mentionable

  belongs_to :group
  belongs_to :user

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit -> {
    message = GroupChatMessage.includes(user: { avatar_attachment: :blob }).find(id)
    broadcast_append_to(
      group,
      :chat,
      target: "chat_messages",
      partial: "shared/chat_message",
      locals: { message: message }
    )
  }
end
