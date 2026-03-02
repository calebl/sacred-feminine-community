module Admin
  module Users
    class InviteLinksController < ApplicationController
      before_action :authenticate_user!

      def create
        @user = User.kept.find(params[:user_id])
        authorize [ :admin, :users, @user ], :copy_invite_link?

        @user.invite!(current_user, skip_invitation: true)

        render json: { url: accept_user_invitation_url(invitation_token: @user.raw_invitation_token) }
      end
    end
  end
end
