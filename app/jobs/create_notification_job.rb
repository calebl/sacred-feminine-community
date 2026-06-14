class CreateNotificationJob < ApplicationJob
  queue_as :default

  # Operational alerts on support threads that should reach their recipients
  # regardless of any block relationship with the actor (e.g. a blocked
  # attendee's help request or a reply on that thread).
  BLOCK_EXEMPT_EVENT_TYPES = %w[help_request help_request_reply].freeze

  def perform(user_id:, actor_id:, event_type:, title:, body:, path:, notifiable_type: nil, notifiable_id: nil, group_key: nil)
    user = User.find_by(id: user_id)
    return unless user
    return if suppressed_for_block?(user, actor_id, event_type)

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
    SendEmailNotificationJob.perform_later(notification.id)
    BroadcastUnreadBadgeJob.perform_later(user_id)

    notification
  end

  private

  # Suppress notifications between users in a block relationship. Blocking
  # hides content mutually, so neither the blocker nor the blocked party
  # should be notified about the other's activity. Operational admin alerts
  # are exempt so they always reach admins.
  def suppressed_for_block?(user, actor_id, event_type)
    return false if actor_id.nil?
    return false if BLOCK_EXEMPT_EVENT_TYPES.include?(event_type)

    user.hidden_content_user_ids.include?(actor_id)
  end

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
