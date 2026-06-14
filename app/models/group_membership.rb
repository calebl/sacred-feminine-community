class GroupMembership < ApplicationRecord
  audited associated_with: :group

  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id, message: "is already a member" }

  after_create_commit :notify_group_of_new_member
  after_commit :broadcast_unread_badge, if: -> { saved_change_to_last_read_at? || saved_change_to_posts_last_read_at? }

  private

  def notify_group_of_new_member
    recipient_ids = group.group_memberships.where.not(user_id: user_id).pluck(:user_id)

    recipient_ids.each do |recipient_id|
      CreateNotificationJob.perform_later(
        user_id: recipient_id,
        actor_id: user_id,
        event_type: "new_member",
        title: user.name,
        body: "Joined #{group.name}",
        path: "/groups/#{group_id}",
        notifiable_type: "Group",
        notifiable_id: group_id
      )
    end
  end

  def broadcast_unread_badge
    BroadcastUnreadBadgeJob.perform_later(user_id)
  end
end
