module PostNotifiable
  extend ActiveSupport::Concern

  included do
    after_create_commit :notify_members_of_new_post
  end

  private

  def notify_members_of_new_post
    recipient_ids = post_container_member_ids - [ user_id ] - mention_recipient_ids

    recipient_ids.each do |rid|
      CreateNotificationJob.perform_later(
        user_id: rid,
        actor_id: user_id,
        event_type: "new_post",
        title: user.name,
        body: new_post_notification_body,
        path: new_post_notification_path,
        notifiable_type: self.class.name,
        notifiable_id: id
      )
    end
  end
end
