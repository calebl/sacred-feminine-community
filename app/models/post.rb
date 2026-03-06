class Post < ApplicationRecord
  include Mentionable

  belongs_to :cohort
  belongs_to :user

  has_many :post_comments, dependent: :destroy
  has_many :post_reads, dependent: :destroy

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  validates :body, presence: true

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
