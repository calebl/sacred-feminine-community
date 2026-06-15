class BroadcastUnreadBadgeJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    content = ApplicationController.render(
      partial: "shared/unread_indicators_stream",
      locals: { user: user }
    )

    Turbo::StreamsChannel.broadcast_stream_to(
      [ user, :unread_badge ],
      content: content
    )
  end
end
