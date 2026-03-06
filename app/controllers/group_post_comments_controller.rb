class GroupPostCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_post

  def create
    @comment = @post.group_post_comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to group_group_post_path(@group, @post) }
      end
    else
      redirect_to group_group_post_path(@group, @post), alert: "Reply could not be saved."
    end
  end

  def destroy
    @comment = @post.group_post_comments.find(params[:id])
    authorize @comment
    @comment.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@comment) }
      format.html { redirect_to group_group_post_path(@group, @post) }
    end
  end

  private

  def set_group
    @group = Group.kept.find(params[:group_id])
  end

  def set_post
    @post = @group.group_posts.find(params[:group_post_id])
  end

  def comment_params
    params.require(:group_post_comment).permit(:body, :parent_id)
  end
end
