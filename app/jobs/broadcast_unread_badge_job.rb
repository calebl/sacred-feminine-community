class BroadcastUnreadBadgeJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    count = ApplicationController.helpers.total_unread_count(user)

    content = ApplicationController.render(
      partial: "shared/unread_badge_stream",
      locals: { count: count }
    )

    Turbo::StreamsChannel.broadcast_stream_to(
      [user, :unread_badge],
      content: content
    )
  end
end
