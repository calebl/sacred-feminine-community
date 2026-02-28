class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, if: :policy_scope_required?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /^rails\//
  end

  def policy_scope_required?
    false
  end
end
