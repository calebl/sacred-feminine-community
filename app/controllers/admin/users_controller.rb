module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize [:admin, User]
      @users = User.discarded.order(:name)
    end

    def update
      @user = User.discarded.find(params[:id])
      authorize [:admin, @user]
      @user.undiscard!
      redirect_to admin_dashboard_path, notice: "#{@user.name} has been restored."
    end

    def destroy
      @user = User.find(params[:id])
      authorize [:admin, @user]

      if @user == current_user
        redirect_to admin_dashboard_path, alert: "You cannot remove yourself."
        return
      end

      if @user.invitation_accepted_at.nil?
        @user.destroy!
        redirect_to admin_dashboard_path, notice: "Invitation for #{@user.email} has been cancelled."
      else
        @user.discard!
        redirect_to admin_dashboard_path, notice: "#{@user.name} has been removed."
      end
    end
  end
end
