class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]
  layout "dashboard"

  def index
    skip_authorization
    load_sidebar
    @groups = policy_scope(Group).includes(:members).with_attached_header_image.order(:name)
  end

  def show
    authorize @group
    @active_tab = params[:tab].presence || "feed"
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
    @active_group_id = @group.id
    @is_member = @group.member?(current_user)

    return unless @is_member

    unless request.headers["Purpose"] == "prefetch"
      membership = @group.group_memberships.find_by(user: current_user)
      if membership
        updates = { last_read_at: Time.current }
        updates[:posts_last_read_at] = Time.current if @active_tab == "feed"
        membership.update(updates)
      end
      broadcast_unread_badge
    end
    @members = @group.members.kept.includes(:group_memberships).load
    @posts = @group.group_posts.pinned_first.includes(:user, group_post_comments: :user)
  end

  def new
    @group = Group.new
    authorize @group
    load_sidebar
  end

  def create
    @group = Group.new(group_params)
    @group.creator = current_user
    authorize @group

    if @group.save
      redirect_to @group, notice: "Group created."
    else
      load_sidebar
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @group
    load_sidebar
    @active_group_id = @group.id
  end

  def update
    authorize @group
    if @group.update(group_params)
      @group.header_image.purge if params[:group][:remove_header_image] == "1" && !params[:group][:header_image].present?
      redirect_to @group, notice: "Group updated."
    else
      load_sidebar
      @active_group_id = @group.id
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @group
    @group.discard
    redirect_to groups_path, notice: "Group archived."
  end

  private

  def set_group
    @group = Group.kept.find(params[:id])
  end

  def load_sidebar
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
  end

  def group_params
    params.require(:group).permit(:name, :description, :header_image)
  end

  def policy_scope_required?
    action_name == "index"
  end
end
