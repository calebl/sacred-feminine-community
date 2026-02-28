module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :admin_dashboard
      @users_count = User.count
      @cohorts_count = defined?(Cohort) ? Cohort.count : 0
      @pending_invitations = User.invitation_not_accepted.count
    end
  end
end
