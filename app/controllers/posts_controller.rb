class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort
  before_action :set_post, only: [ :show, :destroy, :pin ]

  def show
    authorize @post
    unless request.headers["Purpose"] == "prefetch"
      PostRead.find_or_initialize_by(post: @post, user: current_user)
              .update(last_read_at: Time.current)
      Mention.unread
             .where(user: current_user, mentionable_type: "PostComment")
             .where(mentionable_id: @post.post_comments.select(:id))
             .update_all(read_at: Time.current)
    end
    @comments = @post.post_comments.top_level.includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ]).order(created_at: :asc)
    @new_comment = @post.post_comments.build
  end

  def create
    @post = @cohort.posts.build(post_params)
    @post.user = current_user
    authorize @post

    if @post.save
      if params[:inline_feed]
        redirect_to cohort_path(@cohort, tab: :feed), notice: "Post published."
      else
        redirect_to cohort_post_path(@cohort, @post), notice: "Post created."
      end
    else
      if params[:inline_feed]
        load_cohort_show_data
        render "cohorts/show", layout: "dashboard", status: :unprocessable_entity
      end
    end
  end

  def destroy
    authorize @post
    @post.destroy
    redirect_to cohort_path(@cohort, tab: :feed), notice: "Post deleted."
  end

  def pin
    authorize @post
    @post.update(pinned: !@post.pinned)
    redirect_to cohort_path(@cohort, tab: :feed), notice: @post.pinned? ? "Post pinned." : "Post unpinned."
  end

  private

  def set_cohort
    @cohort = Cohort.kept.find(params[:cohort_id])
  end

  def set_post
    @post = @cohort.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:body)
  end

  def load_cohort_show_data
    @active_tab = "feed"
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_cohort_id = @cohort.id
    @members = @cohort.members.kept.includes(:cohort_memberships).load
    @membership_ids = CohortMembership.where(cohort: @cohort, user_id: @members.map(&:id)).pluck(:user_id, :id).to_h
    @non_members = User.kept.where.not(id: @members.map(&:id)).where.not(invitation_accepted_at: nil).order(:name).pluck(:name, :id)
    @chat_messages = @cohort.chat_messages.includes(:user).order(created_at: :desc).limit(50).reverse
    @posts = @cohort.posts.pinned_first.includes(:user, :post_comments)
    @show_form = true
  end
end
