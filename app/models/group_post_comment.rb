class GroupPostComment < ApplicationRecord
  include Mentionable
  include Reactable
  include CommentNotifiable

  belongs_to :group_post
  belongs_to :user
  belongs_to :parent, class_name: "GroupPostComment", optional: true

  has_many :replies, class_name: "GroupPostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  scope :top_level, -> { where(parent_id: nil) }

  private

  def commentable_post = group_post
  def commentable_comments = group_post.group_post_comments

  def comment_notification_body
    "Commented in #{group_post.group.name}"
  end

  def comment_notification_path
    "/groups/#{group_post.group_id}/group_posts/#{group_post_id}"
  end
end
