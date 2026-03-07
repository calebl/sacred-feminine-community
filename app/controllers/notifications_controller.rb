class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    skip_authorization
    @notifications = policy_scope(Notification).recent.includes(:actor)
  end
end
