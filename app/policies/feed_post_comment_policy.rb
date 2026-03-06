class FeedPostCommentPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    user.admin? || record.user == user
  end
end
