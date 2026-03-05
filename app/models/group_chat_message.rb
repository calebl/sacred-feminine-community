class GroupChatMessage < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit -> {
    message = GroupChatMessage.includes(user: { avatar_attachment: :blob }).find(id)
    broadcast_append_to(
      group,
      :chat,
      target: "chat_messages",
      partial: "group_chat_messages/group_chat_message",
      locals: { group_chat_message: message }
    )
  }
end
