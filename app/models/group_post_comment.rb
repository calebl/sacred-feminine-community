class GroupPostComment < ApplicationRecord
  include Mentionable
  include Reactable
  include CommentNotifiable
  include Blockable

  belongs_to :group_post
  belongs_to :user
  belongs_to :parent, class_name: "GroupPostComment", optional: true

  has_many :replies, class_name: "GroupPostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  scope :top_level, -> { where(parent_id: nil) }

  # Cleared when this comment scrolls into view: its own mention plus the parent
  # post's grouped new_comment row (one row covers all new comments on a post).
  def mark_seen_by(user)
    Notification.unread.where(user: user, notifiable_type: "GroupPostComment",
                              notifiable_id: id, event_type: "mention")
               .update_all(read_at: Time.current)
    Notification.unread.where(user: user, notifiable_type: "GroupPost",
                              notifiable_id: group_post_id, event_type: "new_comment")
               .update_all(read_at: Time.current)
  end

  private

  def commentable_post = group_post
  def commentable_comments = group_post.group_post_comments

  def comment_notification_body
    "Commented in #{group_post.group.name}"
  end

  def comment_notification_path
    "/groups/#{group_post.group_id}/group_posts/#{group_post_id}"
  end
end
