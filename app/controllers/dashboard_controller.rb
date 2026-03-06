class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def show
    skip_authorization
    @members = User.active_users.order(:name)
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_tab = params[:tab].presence || "feed"
    @feed_posts = policy_scope(FeedPost).pinned_first.includes(:user, :feed_post_comments)
    @new_feed_post = FeedPost.new
  end
end
