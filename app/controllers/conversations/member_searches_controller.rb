module Conversations
  class MemberSearchesController < ApplicationController
    before_action :authenticate_user!

    def index
      skip_authorization

      @users = if params[:q].present?
        User.active_users
            .with_attached_avatar
            .where.not(id: current_user.id)
            .where("name LIKE ?", "%#{User.sanitize_sql_like(params[:q].strip)}%")
            .order(:name)
            .limit(10)
      else
        User.none
      end

      render layout: false
    end
  end
end
