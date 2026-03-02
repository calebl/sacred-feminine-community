module Admin
  module Users
    class RolesController < ApplicationController
      before_action :authenticate_user!

      def update
        @user = User.kept.find(params[:user_id])
        authorize [ :admin, :users, @user ], :update_role?

        if @user == current_user
          redirect_to admin_dashboard_path, alert: "You cannot change your own role."
          return
        end

        new_role = @user.admin? ? :attendee : :admin
        @user.update!(role: new_role)
        redirect_to admin_dashboard_path, notice: "#{@user.name} is now #{new_role == :admin ? 'an admin' : 'an attendee'}."
      end
    end
  end
end
