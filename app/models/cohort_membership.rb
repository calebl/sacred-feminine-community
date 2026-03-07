class CohortMembership < ApplicationRecord
  audited associated_with: :cohort

  belongs_to :user
  belongs_to :cohort

  validates :user_id, uniqueness: { scope: :cohort_id, message: "is already a member" }

  after_commit :broadcast_unread_badge, if: -> { saved_change_to_last_read_at? || saved_change_to_posts_last_read_at? }

  private

  def broadcast_unread_badge
    BroadcastUnreadBadgeJob.perform_later(user_id)
  end
end
