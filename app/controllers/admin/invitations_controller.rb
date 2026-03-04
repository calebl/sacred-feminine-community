module Admin
  class InvitationsController < Devise::InvitationsController
    before_action :authenticate_user!, except: [ :edit, :update ]
    before_action :authorize_admin!, except: [ :edit, :update ]

    def new
      self.resource = resource_class.new
      @cohorts = Cohort.kept.order(:retreat_start_date)
    end

    def create
      skip_email = params[:delivery_method] == "link"
      self.resource = resource_class.invite!(invite_params, current_user) do |u|
        u.skip_invitation = skip_email
      end

      if resource.errors.empty?
        if skip_email
          render json: { url: accept_user_invitation_url(invitation_token: resource.raw_invitation_token) }
        else
          redirect_to admin_dashboard_path, notice: "Invitation sent to #{resource.email}."
        end
      else
        @cohorts = Cohort.kept.order(:retreat_start_date)
        if skip_email
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        else
          render :new, status: :unprocessable_entity
        end
      end
    end

    private

    def authorize_admin!
      unless current_user.admin?
        redirect_to root_path, alert: "Not authorized"
      end
    end

    def invite_params
      params.require(:user).permit(:email, :name, invited_cohort_ids: [])
    end
  end
end
