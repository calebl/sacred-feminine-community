module Api
  module V1
    class DeviceSerializer
      def initialize(api_token, current:)
        @api_token = api_token
        @current = current
      end

      def as_json(*)
        {
          id: @api_token.id,
          name: @api_token.device_name,
          current: @current,
          last_used_at: @api_token.last_used_at,
          created_at: @api_token.created_at
        }
      end
    end
  end
end
