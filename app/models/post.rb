class Post < ApplicationRecord
  belongs_to :cohort
  belongs_to :user

  has_rich_text :body
  has_many :post_comments, dependent: :destroy
  has_many :post_reads, dependent: :destroy

  scope :published, -> { where(draft: false) }
  scope :drafts, -> { where(draft: true) }
  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  validates :title, presence: true, length: { maximum: 200 }, unless: :draft?
  validates :body, presence: true, unless: :draft?
  validate :one_draft_per_cohort_per_user, if: :draft?

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

  def one_draft_per_cohort_per_user
    scope = self.class.drafts.where(cohort_id: cohort_id, user_id: user_id)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:base, "You already have a draft for this cohort") if scope.exists?
  end
end
