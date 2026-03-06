class FeedPosts::PinsController < ApplicationController
  before_action :authenticate_user!

  def update
    @post = FeedPost.find(params[:feed_post_id])
    authorize @post, :pin?

    @post.update(pinned: !@post.pinned)
    redirect_to feed_posts_path, notice: @post.pinned? ? "Post pinned." : "Post unpinned."
  end
end
