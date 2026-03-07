class PostComment < ApplicationRecord
  include Mentionable
  include Reactable
  include CommentNotifiable

  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: "PostComment", optional: true

  has_many :replies, class_name: "PostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  scope :top_level, -> { where(parent_id: nil) }

  private

  def commentable_post = post
  def commentable_comments = post.post_comments

  def comment_notification_body
    "Commented in #{post.cohort.name}"
  end

  def comment_notification_path
    "/cohorts/#{post.cohort_id}/posts/#{post_id}"
  end
end
