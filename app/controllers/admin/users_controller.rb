module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize [ :admin, User ]
      @users = User.discarded.order(:name)
    end

    def update
      @user = User.discarded.find(params[:id])
      authorize [ :admin, @user ]
      @user.undiscard!
      redirect_to admin_dashboard_path, notice: "#{@user.name} has been restored."
    end

    def destroy
      @user = User.find(params[:id])
      authorize [ :admin, @user ]

      if @user == current_user
        redirect_to admin_dashboard_path, alert: "You cannot remove yourself."
        return
      end

      pending_invitation = @user.invitation_accepted_at.nil?
      @user.remove_from_community!(by: current_user)
      if pending_invitation
        redirect_to admin_dashboard_path, notice: "Invitation for #{@user.email} has been cancelled."
      else
        redirect_to admin_dashboard_path, notice: "#{@user.name} has been removed."
      end
    rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordNotFound => error
      redirect_to admin_dashboard_path, alert: error.message
    end
  end
end
