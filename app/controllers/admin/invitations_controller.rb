module Admin
  class InvitationsController < Devise::InvitationsController
    before_action :authenticate_user!, except: [ :edit, :update ]
    before_action :authorize_admin!, except: [ :edit, :update ]

    def new
      self.resource = resource_class.new
    end

    def create
      self.resource = resource_class.invite!(invite_params, current_user)
      if resource.errors.empty?
        redirect_to admin_dashboard_path, notice: "Invitation sent to #{resource.email}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def authorize_admin!
      unless current_user.admin?
        redirect_to root_path, alert: "Not authorized"
      end
    end

    def invite_params
      params.require(:user).permit(:email, :name)
    end
  end
end
