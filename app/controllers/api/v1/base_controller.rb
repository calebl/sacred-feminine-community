module Api
  module V1
    # Base for the native app's JSON API. Requests authenticate with a bearer
    # token from POST /api/v1/session, never with the website's cookie session,
    # and the website's routes never accept these tokens. Authorization goes
    # through the same Pundit policies and scopes as the website, so the API
    # shows exactly what a member would see there.
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods
      include Pundit::Authorization

      before_action :authenticate_api_token!
      after_action :verify_authorized

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      attr_reader :current_api_token

      def current_user
        current_api_token&.user
      end

      private

      # Removed members are locked out the same way Devise locks them out of
      # the website, by asking active_for_authentication?.
      def authenticate_api_token!
        api_token = authenticate_with_http_token { |token, _options| ApiToken.authenticate(token) }

        if api_token&.user&.active_for_authentication?
          @current_api_token = api_token
          api_token.touch_last_used
        else
          request_http_token_authentication("Application", "Invalid or expired token.")
        end
      end

      def request_http_token_authentication(realm = "Application", message = nil)
        headers["WWW-Authenticate"] = %(Bearer realm="#{realm.delete('"')}")
        render_error(:unauthorized, message || "Authentication required.")
      end

      def render_error(status, message)
        render json: { error: message }, status: status
      end

      def render_forbidden
        render_error(:forbidden, "You are not authorized to perform this action.")
      end

      def render_not_found
        render_error(:not_found, "Not found.")
      end

      def render_bad_request(exception)
        render_error(:bad_request, exception.message)
      end
    end
  end
end
