class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :pin ]
  layout "dashboard", only: [ :show, :edit ]

  def show
    authorize @post
    load_sidebar
    unless request.headers["Purpose"] == "prefetch"
      PostRead.find_or_initialize_by(post: @post, user: current_user)
              .update(last_read_at: Time.current)
      @post.mark_mentions_read(current_user)
    end
    @comments = @post.post_comments.top_level.includes(:user, :reactions, replies: [ :user, :reactions, { replies: [ :user, :reactions, { replies: [ :user, :reactions ] } ] } ]).order(created_at: :asc)
    @new_comment = @post.post_comments.build
  end

  def edit
    authorize @post
    load_sidebar
    @editing = true
    @comments = @post.post_comments.top_level.includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ]).order(created_at: :asc)
    @new_comment = @post.post_comments.build
    render :show
  end

  def update
    authorize @post
    if @post.update(post_params)
      if params[:inline_edit]
        @post.reload
        render turbo_stream: turbo_stream.replace(
          dom_id(@post),
          partial: "shared/post_card",
          locals: post_card_locals(@post)
        )
      else
        redirect_to cohort_post_path(@cohort, @post), notice: "Post updated."
      end
    else
      if params[:inline_edit]
        render turbo_stream: turbo_stream.replace(
          dom_id(@post),
          partial: "shared/post_card",
          locals: post_card_locals(@post)
        ), status: :unprocessable_entity
      else
        load_sidebar
        @editing = true
        @comments = @post.post_comments.top_level.includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ]).order(created_at: :asc)
        @new_comment = @post.post_comments.build
        render :show, status: :unprocessable_entity
      end
    end
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

  def post_card_locals(post)
    {
      post: post,
      comments: post.post_comments.includes(:user),
      comment_partial: "post_comments/post_comment",
      comment_locals: { cohort: @cohort, post: post },
      comment_form_model: [ @cohort, post, PostComment.new ],
      edit_path: edit_cohort_post_path(@cohort, post),
      delete_path: cohort_post_path(@cohort, post),
      pin_path: pin_cohort_post_path(@cohort, post),
      mention_data: { mention_cohort_id_value: @cohort.id }
    }
  end

  def load_sidebar
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_cohort_id = @cohort.id
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
    @posts = @cohort.posts.pinned_first.includes(:user, post_comments: :user)
    @show_form = true
  end
end
