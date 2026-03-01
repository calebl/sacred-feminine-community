class PostCommentPolicy < ApplicationPolicy
  def create?
    user.admin? || record.post.cohort.member?(user)
  end

  def destroy?
    user.admin? || record.user == user
  end
end
