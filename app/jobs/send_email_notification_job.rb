class SendEmailNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    user = notification.user
    return unless user
    return unless user.email_enabled_for?(notification.event_type)

    NotificationMailer.new_notification(notification).deliver_now
  end
end
