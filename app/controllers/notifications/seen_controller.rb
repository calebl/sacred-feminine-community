class Notifications::SeenController < ApplicationController
  before_action :authenticate_user!

  # Marks a post/comment's notifications read once it scrolls into view. The
  # marking itself only ever touches the current user's own notifications, but
  # we still gate on the parent post's visibility policy so this endpoint can't
  # be used as an existence oracle for content in cohorts/groups the user can't
  # see. Unknown and unauthorized records return the same 404.
  def create
    skip_authorization

    record = find_record
    return head :not_found unless record && viewable?(record)

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

  # Visibility is decided by the parent post's policy (PostPolicy/GroupPostPolicy
  # #show?), which a comment inherits.
  def viewable?(record)
    post =
      case record
      when Post, GroupPost then record
      when PostComment then record.post
      when GroupPostComment then record.group_post
      end

    Pundit.policy(current_user, post).show?
  end
end
