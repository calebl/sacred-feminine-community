class Notifications::MarkAllReadsController < ApplicationController
  before_action :authenticate_user!

  def create
    skip_authorization
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
