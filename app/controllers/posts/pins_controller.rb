class Posts::PinsController < ApplicationController
  before_action :authenticate_user!

  def update
    @cohort = Cohort.kept.find(params[:cohort_id])
    @post = @cohort.posts.find(params[:post_id])
    authorize @post, :pin?

    @post.update(pinned: !@post.pinned)
    redirect_to cohort_path(@cohort, tab: :feed), notice: @post.pinned? ? "Post pinned." : "Post unpinned."
  end
end
