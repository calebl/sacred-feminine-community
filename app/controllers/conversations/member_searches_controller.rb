module Conversations
  class MemberSearchesController < ApplicationController
    before_action :authenticate_user!

    def index
      # Authorization is handled by authentication; all authenticated users can search members.
      skip_authorization

      @users = if params[:q].present?
        User.search_by_name(params[:q], exclude: current_user)
      else
        User.none
      end

      render layout: false
    end
  end
end
