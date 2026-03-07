class CreateNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id:, actor_id:, event_type:, title:, body:, path:, notifiable_type: nil, notifiable_id: nil, group_key: nil)
    user = User.find_by(id: user_id)
    return unless user

    notification = if group_key.present?
      upsert_grouped(user, actor_id: actor_id, event_type: event_type, title: title, body: body, path: path,
                     notifiable_type: notifiable_type, notifiable_id: notifiable_id, group_key: group_key)
    else
      user.notifications.create!(
        actor_id: actor_id,
        event_type: event_type,
        title: title,
        body: body,
        path: path,
        notifiable_type: notifiable_type,
        notifiable_id: notifiable_id,
        group_key: group_key
      )
    end

    SendPushNotificationJob.perform_later(user_id, title, body, path)
    BroadcastUnreadBadgeJob.perform_later(user_id)

    notification
  end

  private

  def upsert_grouped(user, actor_id:, event_type:, title:, body:, path:, notifiable_type:, notifiable_id:, group_key:)
    existing = user.notifications.unread.find_by(group_key: group_key)

    if existing
      existing.update!(body: body, title: title, actor_id: actor_id,
                       notifiable_type: notifiable_type, notifiable_id: notifiable_id)
      existing
    else
      user.notifications.create!(
        actor_id: actor_id,
        event_type: event_type,
        title: title,
        body: body,
        path: path,
        notifiable_type: notifiable_type,
        notifiable_id: notifiable_id,
        group_key: group_key
      )
    end
  end
end
