class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    skip_authorization
    @announcement = Announcement.current.first
  end
end
