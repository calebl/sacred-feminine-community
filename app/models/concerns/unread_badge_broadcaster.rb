module UnreadBadgeBroadcaster
  extend ActiveSupport::Concern

  private

  def broadcast_unread_badge_to(user_ids)
    Array(user_ids).each do |uid|
      BroadcastUnreadBadgeJob.perform_later(uid)
    end
  end
end
