class GroupPostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]

  def show
    authorize @post
    unless request.headers["Purpose"] == "prefetch"
      GroupPostRead.find_or_initialize_by(group_post: @post, user: current_user)
                   .update(last_read_at: Time.current)
    end
    @comments = @post.group_post_comments.top_level.includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ]).order(created_at: :asc)
    @new_comment = @post.group_post_comments.build
  end

  def new
    @post = @group.group_posts.build
    authorize @post

    draft = @group.group_posts.drafts.find_by(user: current_user)
    if draft
      redirect_to edit_group_group_post_path(@group, draft)
    else
      draft = @group.group_posts.create!(user: current_user, draft: true)
      redirect_to edit_group_group_post_path(@group, draft)
    end
  end

  def edit
    authorize @post
    redirect_to group_group_post_path(@group, @post) unless @post.draft?
  end

  def update
    authorize @post

    if params[:publish]
      @post.draft = false
      if @post.update(post_params)
        if params[:inline_feed]
          redirect_to group_path(@group, tab: :feed), notice: "Post published."
        else
          redirect_to group_group_post_path(@group, @post), notice: "Post published."
        end
      else
        @post.draft = true
        if params[:inline_feed]
          load_group_show_data
          @show_form = true
          render "groups/show", layout: "dashboard", status: :unprocessable_entity
        else
          render :edit, status: :unprocessable_entity
        end
      end
    else
      unless @post.draft?
        redirect_to group_group_post_path(@group, @post)
        return
      end

      @post.update(post_params)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_group_group_post_path(@group, @post), notice: "Draft saved." }
      end
    end
  end

  def create
    @post = @group.group_posts.build(post_params)
    @post.user = current_user
    authorize @post

    if @post.save
      if params[:inline_feed]
        redirect_to group_path(@group, tab: :feed), notice: "Post published."
      else
        redirect_to group_group_post_path(@group, @post), notice: "Post created."
      end
    else
      if params[:inline_feed]
        load_group_show_data
        render "groups/show", layout: "dashboard", status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    authorize @post
    @post.destroy
    redirect_to group_path(@group, tab: :feed), notice: "Post deleted."
  end

  private

  def set_group
    @group = Group.kept.find(params[:group_id])
  end

  def set_post
    @post = @group.group_posts.find(params[:id])
  end

  def post_params
    params.require(:group_post).permit(:body)
  end

  def load_group_show_data
    @active_tab = "feed"
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_group_id = @group.id
    @is_member = true
    @members = @group.members.kept.includes(:group_memberships).load
    @chat_messages = @group.group_chat_messages.includes(:user).order(created_at: :desc).limit(50).reverse
    @posts = @group.group_posts.published.pinned_first.includes(:user, :group_post_comments)
    @draft = @group.group_posts.drafts.find_by(user: current_user)
    @show_form = true
  end
end
