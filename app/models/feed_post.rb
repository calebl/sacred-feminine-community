class FeedPost < ApplicationRecord
  include Mentionable
  include Reactable

  belongs_to :user

  has_many :feed_post_comments, dependent: :destroy
  has_many :feed_post_reads, dependent: :destroy

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  validates :body, presence: true

  def mark_as_read_by(user)
    feed_post_reads
      .find_or_initialize_by(user: user)
      .update(last_read_at: Time.current)

    Mention.unread
           .where(user: user)
           .where(
             "(mentionable_type = 'FeedPost' AND mentionable_id = ?) OR (mentionable_type = 'FeedPostComment' AND mentionable_id IN (?))",
             id, feed_post_comments.select(:id)
           )
           .update_all(read_at: Time.current)
    Notification.unread.where(user: user, event_type: "mention")
               .where("(notifiable_type = 'FeedPost' AND notifiable_id = ?) OR (notifiable_type = 'FeedPostComment' AND notifiable_id IN (?))",
                       id, feed_post_comments.select(:id))
               .update_all(read_at: Time.current)
    Notification.unread.where(user: user, event_type: "new_comment",
                              notifiable_type: "FeedPost", notifiable_id: id)
               .update_all(read_at: Time.current)
  end

  def unread_comment_count(user)
    post_read = feed_post_reads.find_by(user: user)
    comments = feed_post_comments.where.not(user: user)
    if post_read&.last_read_at
      comments.where("feed_post_comments.created_at > ?", post_read.last_read_at).count
    else
      comments.count
    end
  end
end
