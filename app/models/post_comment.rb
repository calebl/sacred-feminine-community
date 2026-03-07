class PostComment < ApplicationRecord
  include Mentionable
  include Reactable

  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: "PostComment", optional: true

  has_many :replies, class_name: "PostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  scope :top_level, -> { where(parent_id: nil) }

  after_create_commit :notify_commenters

  private

  def notify_commenters
    recipient_ids = ([ post.user_id ] + post.post_comments.where.not(user_id: user_id).distinct.pluck(:user_id)).uniq - [ user_id ]
    recipient_ids.each do |rid|
      CreateNotificationJob.perform_later(
        user_id: rid,
        actor_id: user_id,
        event_type: "new_comment",
        title: user.name,
        body: "Commented in #{post.cohort.name}",
        path: "/cohorts/#{post.cohort_id}/posts/#{post_id}",
        notifiable_type: "Post",
        notifiable_id: post_id,
        group_key: "post_comments:#{post_id}"
      )
    end
  end
end
