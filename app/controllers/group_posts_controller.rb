class GroupPostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  layout "dashboard", only: [ :show, :edit ]

  def show
    authorize @post
    load_sidebar
    unless request.headers["Purpose"] == "prefetch"
      GroupPostRead.find_or_initialize_by(group_post: @post, user: current_user)
                   .update(last_read_at: Time.current)
      @post.mark_as_read_by(current_user)
    end
    @comments = @post.group_post_comments.top_level.includes(:user, :reactions, replies: [ :user, :reactions, { replies: [ :user, :reactions, { replies: [ :user, :reactions ] } ] } ]).order(created_at: :asc)
    @new_comment = @post.group_post_comments.build
  end

  def edit
    authorize @post
    load_sidebar
    @editing = true
    @comments = @post.group_post_comments.top_level.includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ]).order(created_at: :asc)
    @new_comment = @post.group_post_comments.build
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
        redirect_to group_group_post_path(@group, @post), notice: "Post updated."
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
        @comments = @post.group_post_comments.top_level.includes(:user, replies: [ :user, { replies: [ :user, { replies: :user } ] } ]).order(created_at: :asc)
        @new_comment = @post.group_post_comments.build
        render :show, status: :unprocessable_entity
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

  def post_card_locals(post)
    {
      post: post,
      comments: post.group_post_comments.includes(:user),
      comment_partial: "group_post_comments/group_post_comment",
      comment_locals: { group: @group, group_post: post },
      comment_form_model: [ @group, post, GroupPostComment.new ],
      edit_path: edit_group_group_post_path(@group, post),
      post_path: group_group_post_path(@group, post),
      pin_path: group_group_post_pin_path(@group, post),
      mention_data: { mention_group_id_value: @group.id }
    }
  end

  def load_sidebar
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_group_id = @group.id
  end

  def load_group_show_data
    @active_tab = "feed"
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_group_id = @group.id
    @is_member = true
    @members = @group.members.kept.includes(:group_memberships).load
    @posts = @group.group_posts.pinned_first.includes(:user, group_post_comments: :user)
    @show_form = true
  end
end
