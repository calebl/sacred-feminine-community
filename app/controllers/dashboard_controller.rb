class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    skip_authorization
    @announcement = Announcement.current.first
    @members = User.active_users.order(:name)
    @announcements = Announcement.where.not(published_at: nil).order(published_at: :desc)
    @active_tab = params[:tab].presence || "map"
  end
end
