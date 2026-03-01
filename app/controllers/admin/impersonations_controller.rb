module Admin
  class ImpersonationsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_development_environment

    def create
      authorize :impersonation

      if impersonating?
        redirect_to admin_dashboard_path, alert: "Already impersonating. Stop first."
        return
      end

      user = User.kept.find(params[:user_id])

      if user == current_user
        redirect_to admin_dashboard_path, alert: "Cannot impersonate yourself."
        return
      end

      session[:admin_user_id] = current_user.id
      session[:impersonated_user_id] = user.id

      redirect_to authenticated_root_path, notice: "Now impersonating #{user.name}."
    end

    def destroy
      authorize :impersonation

      admin = User.find(session[:admin_user_id])
      session.delete(:impersonated_user_id)
      session.delete(:admin_user_id)

      sign_in(:user, admin)

      redirect_to admin_dashboard_path, notice: "Stopped impersonating. Welcome back."
    end

    private

    def require_development_environment
      unless Rails.env.local?
        redirect_to root_path, alert: "This feature is only available in development."
      end
    end
  end
end
