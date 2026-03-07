class FeedPostComment < ApplicationRecord
  include Mentionable
  include Reactable

  belongs_to :feed_post
  belongs_to :user
  belongs_to :parent, class_name: "FeedPostComment", optional: true

  has_many :replies, class_name: "FeedPostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }
  validate :parent_belongs_to_same_post, if: :parent_id?

  scope :top_level, -> { where(parent_id: nil) }

  after_create_commit :notify_commenters

  private

  def notify_commenters
    recipient_ids = ([ feed_post.user_id ] + feed_post.feed_post_comments.where.not(user_id: user_id).distinct.pluck(:user_id)).uniq - [ user_id ]
    recipient_ids.each do |rid|
      CreateNotificationJob.perform_later(
        user_id: rid,
        actor_id: user_id,
        event_type: "new_comment",
        title: user.name,
        body: "Commented on a feed post",
        path: "/feed/#{feed_post_id}",
        notifiable_type: "FeedPost",
        notifiable_id: feed_post_id,
        group_key: "feed_post_comments:#{feed_post_id}"
      )
    end
  end

  def parent_belongs_to_same_post
    if parent && parent.feed_post_id != feed_post_id
      errors.add(:parent_id, "must belong to the same post")
    end
  end
end
