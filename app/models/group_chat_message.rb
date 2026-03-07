class GroupChatMessage < ApplicationRecord
  include Mentionable
  include UnreadBadgeBroadcaster

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

  after_create_commit :send_push_notifications, unless: :system_message?
  after_create_commit :broadcast_unread_badges

  private

  def send_push_notifications
    group.group_memberships.where.not(user_id: user_id).find_each do |membership|
      SendPushNotificationJob.perform_later(
        membership.user_id,
        "#{user.name} in #{group.name}",
        body.truncate(100),
        "/groups/#{group_id}"
      )
    end
  end

  def broadcast_unread_badges
    recipient_ids = group.group_memberships.where.not(user_id: user_id).pluck(:user_id)
    broadcast_unread_badge_to(recipient_ids)
  end
end
