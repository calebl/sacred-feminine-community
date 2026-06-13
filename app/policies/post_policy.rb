class PostPolicy < ApplicationPolicy
  def show?
    user.admin? || record.cohort.member?(user)
  end

  def create?
    user.admin? || record.cohort.member?(user)
  end

  def update?
    record.user == user
  end

  def destroy?
    user.admin? || record.user == user
  end

  def pin?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    # Cohort membership is already enforced by the controller before a cohort's
    # posts are loaded, so the scope's job here is to drop content hidden by a
    # block in either direction. Routing the feed through policy_scope means
    # callers can't forget the block filter.
    def resolve
      scope.visible_to(user)
    end
  end
end
