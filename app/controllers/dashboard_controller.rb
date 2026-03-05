class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def show
    skip_authorization
    @members = User.active_users.order(:name)
    @announcements = Announcement.where.not(published_at: nil).order(published_at: :desc)
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_tab = params[:tab].presence || "announcements"
  end
end
