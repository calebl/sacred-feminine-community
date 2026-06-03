class GroupPostCommentPolicy < ApplicationPolicy
  def create?
    user.admin? || record.group_post.group.member?(user)
  end

  def destroy?
    user.admin? || record.user == user
  end
end
