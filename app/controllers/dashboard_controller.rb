class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def show
    skip_authorization
    @members = User.active_users.order(:name)
    @announcements = Announcement.where.not(published_at: nil).order(published_at: :desc)
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @faqs = Faq.active.ordered
    @active_tab = params[:tab].presence || "announcements"
    @new_announcement = Announcement.new if current_user.admin?
    @new_faq = Faq.new if current_user.admin?
  end
end
