module CommentNotifiable
  extend ActiveSupport::Concern

  included do
    after_create_commit :notify_commenters
  end

  private

  def notify_commenters
    parent_post = commentable_post
    recipient_ids = ([ parent_post.user_id ] + commentable_comments.where.not(user_id: user_id).distinct.pluck(:user_id)).uniq - [ user_id ]
    recipient_ids.each do |rid|
      CreateNotificationJob.perform_later(
        user_id: rid,
        actor_id: user_id,
        event_type: "new_comment",
        title: user.name,
        body: comment_notification_body,
        path: comment_notification_path,
        notifiable_type: parent_post.class.name,
        notifiable_id: parent_post.id,
        group_key: "#{self.class.name.underscore.pluralize}:#{parent_post.id}"
      )
    end
  end
end
