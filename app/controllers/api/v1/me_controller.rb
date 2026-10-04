module Api
  module V1
    class MeController < BaseController
      def show
        authorize current_user, :show_profile?, policy_class: UserPolicy
        render json: { user: MeSerializer.new(current_user).as_json }
      end
    end
  end
end
