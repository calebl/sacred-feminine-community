class FeedPostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  layout "dashboard"

  def index
    authorize FeedPost
    load_sidebar
    @posts = policy_scope(FeedPost).pinned_first.includes(:user, :feed_post_comments)
    @new_post = FeedPost.new
  end

  def show
    authorize @post
    load_sidebar
    @post.mark_as_read_by(current_user) unless request.headers["Purpose"] == "prefetch"
    @comments = @post.feed_post_comments.top_level
                     .includes(:user, :reactions, replies: [ :user, :reactions, { replies: [ :user, :reactions, { replies: [ :user, :reactions ] } ] } ])
                     .order(created_at: :asc)
    @new_comment = @post.feed_post_comments.build
  end

  def edit
    authorize @post
    load_sidebar
    @editing = true
    @comments = @post.feed_post_comments.top_level
                     .includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ])
                     .order(created_at: :asc)
    @new_comment = @post.feed_post_comments.build
    render :show
  end

  def update
    authorize @post
    if @post.update(post_params)
      redirect_to feed_post_path(@post), notice: "Post updated."
    else
      load_sidebar
      @editing = true
      @comments = @post.feed_post_comments.top_level
                       .includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ])
                       .order(created_at: :asc)
      @new_comment = @post.feed_post_comments.build
      render :show, status: :unprocessable_entity
    end
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
        @posts = policy_scope(FeedPost).pinned_first.includes(:user, :feed_post_comments)
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
