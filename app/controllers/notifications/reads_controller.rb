class Notifications::ReadsController < ApplicationController
  before_action :authenticate_user!

  def create
    @notification = current_user.notifications.find(params[:notification_id])
    authorize @notification, :update?
    @notification.update!(read_at: Time.current) unless @notification.read?
    redirect_to @notification.path || notifications_path
  end
end
