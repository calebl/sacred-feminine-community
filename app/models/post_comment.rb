class PostComment < ApplicationRecord
  include Mentionable
  include Reactable
  include CommentNotifiable
  include Blockable

  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: "PostComment", optional: true

  has_many :replies, class_name: "PostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }
  validate :parent_belongs_to_same_post, if: :parent_id?

  scope :top_level, -> { where(parent_id: nil) }

  # Nested replies `viewer` is allowed to see, oldest first. Rendering always
  # goes through here so a reply obeys the same hiding rules as a top-level
  # comment — the association itself is preloaded but unfiltered.
  def visible_replies(viewer)
    PostComment.reject_hidden_from(replies_with_authors, viewer).sort_by(&:created_at)
  end

  # Cleared when this comment scrolls into view: its own mention plus the parent
  # post's grouped new_comment row (one row covers all new comments on a post).
  def mark_seen_by(user)
    Notification.unread.where(user: user, notifiable_type: "PostComment",
                              notifiable_id: id, event_type: "mention")
               .update_all(read_at: Time.current)
    Notification.unread.where(user: user, notifiable_type: "Post",
                              notifiable_id: post_id, event_type: "new_comment")
               .update_all(read_at: Time.current)
  end

  private

  # Feeds and post pages preload replies and their authors, and adding an
  # `includes` to an already-loaded association would throw that away and query
  # per comment. Only the turbo_stream reply path arrives here unloaded.
  def replies_with_authors
    replies.loaded? ? replies : replies.includes(:user)
  end

  def commentable_post = post
  def commentable_comments = post.post_comments

  def comment_notification_body
    "Commented in #{post.cohort.name}"
  end

  def comment_notification_path
    "/cohorts/#{post.cohort_id}/posts/#{post_id}"
  end

  def parent_belongs_to_same_post
    if parent && parent.post_id != post_id
      errors.add(:parent_id, "must belong to the same post")
    end
  end
end
