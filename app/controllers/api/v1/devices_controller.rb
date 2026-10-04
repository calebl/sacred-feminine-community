module Api
  module V1
    # The devices signed in to the member's account, each one an ApiToken.
    # Revoking a device signs it out on its next request.
    class DevicesController < BaseController
      after_action :verify_policy_scoped, only: :index

      def index
        authorize ApiToken
        devices = policy_scope(ApiToken).order(created_at: :desc)
        render json: { devices: devices.map { |device| DeviceSerializer.new(device, current: device == current_api_token).as_json } }
      end

      def destroy
        device = policy_scope(ApiToken).find(params[:id])
        authorize device
        device.destroy!
        head :no_content
      end
    end
  end
end
