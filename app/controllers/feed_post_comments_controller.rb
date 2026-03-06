class FeedPostCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    @comment = @post.feed_post_comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to feed_post_path(@post) }
      end
    else
      redirect_to feed_post_path(@post), alert: "Reply could not be saved."
    end
  end

  def destroy
    @comment = @post.feed_post_comments.find(params[:id])
    authorize @comment
    @comment.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@comment) }
      format.html { redirect_to feed_post_path(@post) }
    end
  end

  private

  def set_post
    @post = FeedPost.find(params[:feed_post_id])
  end

  def comment_params
    params.require(:feed_post_comment).permit(:body, :parent_id)
  end
end
