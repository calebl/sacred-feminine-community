class NotificationMailer < ApplicationMailer
  def new_notification(notification)
    @notification = notification
    @user = notification.user
    @notification_url = build_url(notification.path)
    @settings_url = edit_profile_url(@user)

    mail(to: @user.email, subject: notification.title)
  end

  private

  def build_url(path)
    return root_url if path.blank?

    "#{root_url.chomp('/')}#{path}"
  end
end
