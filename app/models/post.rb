class Post < ApplicationRecord
  include Mentionable
  include Reactable

  belongs_to :cohort
  belongs_to :user

  has_many :post_comments, dependent: :destroy
  has_many :post_reads, dependent: :destroy

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  validates :body, presence: true

  def mark_mentions_read(user)
    Mention.unread.where(user: user, mentionable: self).update_all(read_at: Time.current)
    Mention.unread.where(user: user, mentionable_type: "PostComment", mentionable_id: post_comments.select(:id))
           .update_all(read_at: Time.current)
    Notification.unread.where(user: user, event_type: "mention")
               .where("(notifiable_type = 'Post' AND notifiable_id = ?) OR (notifiable_type = 'PostComment' AND notifiable_id IN (?))",
                       id, post_comments.select(:id))
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
end
