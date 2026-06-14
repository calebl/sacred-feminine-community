class Post < ApplicationRecord
  include Mentionable
  include Reactable
  include HasPhotos
  include PostNotifiable
  include Blockable

  belongs_to :cohort
  belongs_to :user

  has_many :post_comments, dependent: :destroy
  has_many :post_reads, dependent: :destroy

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  validates :body, presence: true

  def mark_as_read_by(user)
    Notification.unread.where(user: user, event_type: "mention")
               .where("(notifiable_type = 'Post' AND notifiable_id = ?) OR (notifiable_type = 'PostComment' AND notifiable_id IN (?))",
                       id, post_comments.select(:id))
               .update_all(read_at: Time.current)
    Notification.unread.where(user: user, event_type: [ "new_comment", "new_post" ],
                              notifiable_type: "Post", notifiable_id: id)
               .update_all(read_at: Time.current)
  end

  # Cleared when the post card scrolls into view in a feed: the post itself
  # (new_post + mention), but NOT comments — those clear when seen individually.
  def mark_seen_by(user)
    Notification.unread.where(user: user, notifiable_type: "Post", notifiable_id: id,
                              event_type: [ "new_post", "mention" ])
               .update_all(read_at: Time.current)
  end

  def unread_comment_count(user)
    post_read = post_reads.find_by(user: user)
    comments = post_comments.where.not(user: user)
    if post_read&.last_read_at
      comments.where("post_comments.created_at > ?", post_read.last_read_at).count
    else
      comments.count
    end
  end

  private

  def post_container_member_ids
    cohort.cohort_memberships.pluck(:user_id)
  end

  def new_post_notification_body
    "Posted in #{cohort.name}"
  end

  def new_post_notification_path
    "/cohorts/#{cohort_id}/posts/#{id}"
  end
end
