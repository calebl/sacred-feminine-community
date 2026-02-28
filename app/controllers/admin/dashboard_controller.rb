module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :admin_dashboard
      @users_count = User.count
      @cohorts_count = Cohort.count
      @pending_invitations = User.invitation_not_accepted.count
    end
  end
end
