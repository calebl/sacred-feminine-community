class FeedPostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :show, :destroy ]
  layout "dashboard"

  def index
    authorize FeedPost
    load_sidebar
    @posts = FeedPost.pinned_first.includes(:user, :feed_post_comments)
    @new_post = FeedPost.new
  end

  def show
    authorize @post
    load_sidebar
    unless request.headers["Purpose"] == "prefetch"
      FeedPostRead.find_or_initialize_by(feed_post: @post, user: current_user)
                  .update(last_read_at: Time.current)
      Mention.unread
             .where(user: current_user, mentionable_type: "FeedPostComment")
             .where(mentionable_id: @post.feed_post_comments.select(:id))
             .update_all(read_at: Time.current)
    end
    @comments = @post.feed_post_comments.top_level
                     .includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ])
                     .order(created_at: :asc)
    @new_comment = @post.feed_post_comments.build
  end

  def create
    @post = FeedPost.new(post_params)
    @post.user = current_user
    authorize @post

    if @post.save
      if params[:inline_feed]
        redirect_to feed_posts_path, notice: "Post published."
      else
        redirect_to feed_post_path(@post), notice: "Post created."
      end
    else
      if params[:inline_feed]
        load_sidebar
        @posts = FeedPost.pinned_first.includes(:user, :feed_post_comments)
        @new_post = @post
        render :index, status: :unprocessable_entity
      end
    end
  end

  def destroy
    authorize @post
    @post.destroy
    redirect_to feed_posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = FeedPost.find(params[:id])
  end

  def post_params
    params.require(:feed_post).permit(:body)
  end

  def load_sidebar
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_tab = "feed"
  end
end
