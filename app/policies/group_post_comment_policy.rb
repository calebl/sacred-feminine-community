class GroupPostCommentPolicy < ApplicationPolicy
  def create?
    record.group_post.group.can_participate?(user)
  end

  def destroy?
    user.admin? || record.user == user
  end
end
