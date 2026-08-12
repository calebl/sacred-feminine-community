class FeedPostComment < ApplicationRecord
  include Mentionable
  include Reactable
  include CommentNotifiable
  include Blockable

  belongs_to :feed_post
  belongs_to :user
  belongs_to :parent, class_name: "FeedPostComment", optional: true

  has_many :replies, class_name: "FeedPostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }
  validate :parent_belongs_to_same_post, if: :parent_id?

  scope :top_level, -> { where(parent_id: nil) }

  # Nested replies `viewer` is allowed to see, oldest first. Rendering always
  # goes through here so a reply obeys the same hiding rules as a top-level
  # comment — the association itself is preloaded but unfiltered.
  def visible_replies(viewer)
    FeedPostComment.reject_hidden_from(replies_with_authors, viewer).sort_by(&:created_at)
  end

  private

  # Feeds and post pages preload replies and their authors, and adding an
  # `includes` to an already-loaded association would throw that away and query
  # per comment. Only the turbo_stream reply path arrives here unloaded.
  def replies_with_authors
    replies.loaded? ? replies : replies.includes(:user)
  end

  def commentable_post = feed_post
  def commentable_comments = feed_post.feed_post_comments

  def comment_notification_body
    "Commented on a feed post"
  end

  def comment_notification_path
    "/feed/#{feed_post_id}"
  end

  def parent_belongs_to_same_post
    if parent && parent.feed_post_id != feed_post_id
      errors.add(:parent_id, "must belong to the same post")
    end
  end
end
