class GroupPost < ApplicationRecord
  belongs_to :group
  belongs_to :user

  has_many :group_post_comments, dependent: :destroy
  has_many :group_post_reads, dependent: :destroy

  scope :published, -> { where(draft: false) }
  scope :drafts, -> { where(draft: true) }
  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  validates :body, presence: true, unless: :draft?
  validate :one_draft_per_group_per_user, if: :draft?

  def has_content?
    body.present?
  end

  def unread_comment_count(user)
    post_read = group_post_reads.find_by(user: user)
    comments = group_post_comments.where.not(user: user)
    if post_read&.last_read_at
      comments.where("group_post_comments.created_at > ?", post_read.last_read_at).count
    else
      comments.count
    end
  end

  private

  def one_draft_per_group_per_user
    scope = self.class.drafts.where(group_id: group_id, user_id: user_id)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:base, "You already have a draft for this group") if scope.exists?
  end
end
