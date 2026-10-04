module Api
  module V1
    # Sign in and out of the native app. Signing in checks the password through
    # Devise and returns a new token for the named device, once.
    class SessionsController < BaseController
      skip_before_action :authenticate_api_token!, only: :create

      rate_limit to: 10, within: 3.minutes, only: :create, store: Rails.cache,
        with: -> { render_error(:too_many_requests, "Too many sign-in attempts. Try again later.") }

      def create
        skip_authorization
        email = params[:email].to_s.strip.downcase
        password = params[:password].to_s
        device_name = params[:device_name].to_s.strip.first(100)

        if email.blank? || password.blank? || device_name.blank?
          return render_error(:unprocessable_entity, "Email, password, and device name are required.")
        end

        user = User.find_for_authentication(email: email)
        unless user&.valid_password?(password)
          return render_error(:unauthorized, "Invalid email or password.")
        end

        unless user.active_for_authentication?
          return render_error(:unauthorized, "This account cannot sign in.")
        end

        api_token = ApiToken.issue!(user: user, device_name: device_name)
        render json: {
          token: api_token.token,
          device: DeviceSerializer.new(api_token, current: true).as_json,
          user: MeSerializer.new(user).as_json
        }, status: :created
      end

      def destroy
        authorize current_api_token
        current_api_token.destroy!
        head :no_content
      end
    end
  end
end
