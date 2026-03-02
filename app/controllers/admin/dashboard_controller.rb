module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :admin_dashboard
      @users_count = User.kept.where.not(invitation_accepted_at: nil).count
      @cohorts_count = Cohort.kept.count
      @pending_invitations_count = User.kept.invitation_not_accepted.count
      @removed_users_count = User.discarded.count
      @admin_users = User.kept.where.not(invitation_accepted_at: nil).admin.order(:name)
      @active_users = User.kept.where.not(invitation_accepted_at: nil).attendee.order(:name)
      @pending_users = User.kept.invitation_not_accepted.order(:created_at)
    end
  end
end
