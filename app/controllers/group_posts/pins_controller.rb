class GroupPosts::PinsController < ApplicationController
  before_action :authenticate_user!

  def update
    @group = Group.kept.find(params[:group_id])
    @post = @group.group_posts.find(params[:group_post_id])
    authorize @post, :pin?

    @post.update(pinned: !@post.pinned)
    redirect_to group_path(@group, tab: :feed), notice: @post.pinned? ? "Post pinned." : "Post unpinned."
  end
end
