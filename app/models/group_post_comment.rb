class GroupPostComment < ApplicationRecord
  include Mentionable
  include Reactable

  belongs_to :group_post
  belongs_to :user
  belongs_to :parent, class_name: "GroupPostComment", optional: true

  has_many :replies, class_name: "GroupPostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  scope :top_level, -> { where(parent_id: nil) }

  after_create_commit :notify_commenters

  private

  def notify_commenters
    recipient_ids = ([ group_post.user_id ] + group_post.group_post_comments.where.not(user_id: user_id).distinct.pluck(:user_id)).uniq - [ user_id ]
    recipient_ids.each do |rid|
      CreateNotificationJob.perform_later(
        user_id: rid,
        actor_id: user_id,
        event_type: "new_comment",
        title: user.name,
        body: "Commented in #{group_post.group.name}",
        path: "/groups/#{group_post.group_id}/group_posts/#{group_post_id}",
        notifiable_type: "GroupPost",
        notifiable_id: group_post_id,
        group_key: "group_post_comments:#{group_post_id}"
      )
    end
  end
end
