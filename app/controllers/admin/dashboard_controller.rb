module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :admin_dashboard
      @users_count = User.count
      @cohorts_count = Cohort.kept.count
      @pending_invitations = User.invitation_not_accepted.count
      @users = User.order(:name)
    end
  end
end
