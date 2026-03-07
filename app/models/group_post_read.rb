class GroupPostRead < ApplicationRecord
  belongs_to :group_post
  belongs_to :user

  after_commit :broadcast_unread_badge, if: -> { saved_change_to_last_read_at? }

  private

  def broadcast_unread_badge
    BroadcastUnreadBadgeJob.perform_later(user_id)
  end
end
