class Notifications::SeenController < ApplicationController
  before_action :authenticate_user!

  # Marks a post/comment's notifications read once it scrolls into view. Like
  # MarkAllReadsController, this only ever touches the current user's own
  # notifications (the model methods are scoped to the user), so no per-record
  # authorization is needed.
  def create
    skip_authorization

    record = find_record
    return head :not_found unless record

    record.mark_seen_by(current_user)
    BroadcastUnreadBadgeJob.perform_later(current_user.id)
    head :ok
  end

  private

  def find_record
    case params[:type]
    when "post" then Post.find_by(id: params[:id])
    when "post_comment" then PostComment.find_by(id: params[:id])
    when "group_post" then GroupPost.find_by(id: params[:id])
    when "group_post_comment" then GroupPostComment.find_by(id: params[:id])
    end
  end
end
