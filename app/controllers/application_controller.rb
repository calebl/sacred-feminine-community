class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ActionView::RecordIdentifier

  allow_browser versions: :modern
  stale_when_importmap_changes

  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, if: :policy_scope_required?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :impersonating?, :true_current_user

  def current_user
    if impersonating?
      @impersonated_user ||= User.kept.find_by(id: session[:impersonated_user_id])
    else
      super
    end
  end

  def true_current_user
    if session[:admin_user_id].present?
      @true_current_user ||= User.find_by(id: session[:admin_user_id])
    else
      warden.authenticate(scope: :user)
    end
  end

  def impersonating?
    Rails.env.local? && session[:impersonated_user_id].present? && session[:admin_user_id].present?
  end

  private

  def broadcast_unread_badge
    BroadcastUnreadBadgeJob.perform_later(current_user.id) if current_user
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /^rails\// || params[:controller] =~ /^mission_control\//
  end

  def policy_scope_required?
    false
  end
end
