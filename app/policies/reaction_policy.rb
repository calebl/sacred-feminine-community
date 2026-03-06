class ReactionPolicy < ApplicationPolicy
  def create?
    case record.reactable
    when Post, PostComment
      post = record.reactable.is_a?(Post) ? record.reactable : record.reactable.post
      user.admin? || post.cohort.member?(user)
    when GroupPost, GroupPostComment
      group = record.reactable.is_a?(GroupPost) ? record.reactable.group : record.reactable.group_post.group
      group.member?(user)
    when FeedPost, FeedPostComment
      true
    else
      false
    end
  end

  def destroy?
    record.user == user
  end
end
