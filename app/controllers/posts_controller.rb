class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :pin ]

  def show
    authorize @post
    unless request.headers["Purpose"] == "prefetch"
      PostRead.find_or_initialize_by(post: @post, user: current_user)
              .update(last_read_at: Time.current)
    end
    @comments = @post.post_comments.includes(:user).order(created_at: :asc)
    @new_comment = @post.post_comments.build
  end

  def new
    @post = @cohort.posts.build
    authorize @post

    draft = @cohort.posts.drafts.find_by(user: current_user)
    if draft
      redirect_to edit_cohort_post_path(@cohort, draft)
    else
      draft = @cohort.posts.create!(user: current_user, draft: true)
      redirect_to edit_cohort_post_path(@cohort, draft)
    end
  end

  def edit
    authorize @post
    redirect_to cohort_post_path(@cohort, @post) unless @post.draft?
  end

  def update
    authorize @post

    if params[:publish]
      @post.draft = false
      if @post.update(post_params)
        redirect_to cohort_post_path(@cohort, @post), notice: "Post published."
      else
        @post.draft = true
        render :edit, status: :unprocessable_entity
      end
    else
      @post.assign_attributes(post_params)
      @post.save(validate: false)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_cohort_post_path(@cohort, @post), notice: "Draft saved." }
      end
    end
  end

  def create
    @post = @cohort.posts.build(post_params)
    @post.user = current_user
    authorize @post

    if @post.save
      redirect_to cohort_post_path(@cohort, @post), notice: "Post created."
    else
      render :new, status: :unprocessable_entity
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
    params.require(:post).permit(:title, :body)
  end
end
