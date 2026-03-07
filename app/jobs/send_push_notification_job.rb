class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title, body, path)
    user = User.find_by(id: user_id)
    return unless user

    vapid = Rails.application.config.vapid
    return if vapid[:public_key].blank? || vapid[:private_key].blank?

    count = ApplicationController.helpers.total_unread_count(user)

    payload = {
      title: title,
      options: {
        body: body,
        icon: "/icon-192.png",
        badge: "/icon-192.png",
        data: { path: path, unread_count: count }
      }
    }.to_json

    user.push_subscriptions.find_each do |subscription|
      WebPush.payload_send(
        message: payload,
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh_key,
        auth: subscription.auth_key,
        vapid: {
          subject: vapid[:subject],
          public_key: vapid[:public_key],
          private_key: vapid[:private_key]
        }
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      subscription.destroy
    rescue WebPush::ResponseError
      # Push service temporarily unavailable; skip this subscription
    end
  end
end
