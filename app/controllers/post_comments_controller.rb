class PostCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort
  before_action :set_post

  def create
    @comment = @post.post_comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cohort_post_path(@cohort, @post) }
      end
    else
      redirect_to cohort_post_path(@cohort, @post), alert: "Comment could not be saved."
    end
  end


  def destroy
    @comment = @post.post_comments.find(params[:id])
    authorize @comment
    @comment.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@comment) }
      format.html { redirect_to cohort_post_path(@cohort, @post) }
    end
  end

  private

  def set_cohort
    @cohort = Cohort.kept.find(params[:cohort_id])
  end

  def set_post
    @post = @cohort.posts.find(params[:post_id])
  end

  def comment_params
    params.require(:post_comment).permit(:body, :parent_id)
  end
end
