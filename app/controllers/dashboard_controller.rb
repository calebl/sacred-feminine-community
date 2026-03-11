class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def show
    skip_authorization
    @members = User.active_users.order(:name)
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_tab = params[:tab].presence || "feed"
    @new_feed_post = FeedPost.new
    @feed_items = build_feed_items
  end

  private

  def build_feed_items
    items = []

    policy_scope(FeedPost).includes(:user, feed_post_comments: :user).find_each do |post|
      items << FeedItem.new(post: post, source_type: :community, source_name: "Community Feed", visibility: "All members")
    end

    current_user.cohorts.includes(posts: [:user, { post_comments: :user }]).find_each do |cohort|
      cohort.posts.each do |post|
        items << FeedItem.new(post: post, source_type: :cohort, source_name: cohort.name, visibility: "#{cohort.name} members")
      end
    end

    current_user.groups.includes(group_posts: [:user, { group_post_comments: :user }]).find_each do |group|
      group.group_posts.each do |post|
        items << FeedItem.new(post: post, source_type: :group, source_name: group.name, visibility: "#{group.name} members")
      end
    end

    items.sort_by { |item| [item.post.pinned? ? 0 : 1, -item.post.created_at.to_i] }
  end

  FeedItem = Data.define(:post, :source_type, :source_name, :visibility)
end
