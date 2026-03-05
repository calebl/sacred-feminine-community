class GroupPostCommentPolicy < ApplicationPolicy
  def create?
    record.group_post.group.member?(user)
  end

  def destroy?
    user.admin? || record.user == user
  end
end
