class FeedPostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    !user.hides_content_from?(record.user)
  end

  def create?
    true
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
    # The community feed is visible to all members, minus content hidden by a
    # block or a cohort gender preference in either direction. Keeping the
    # filter here means every caller of policy_scope(FeedPost) gets it.
    def resolve
      scope.visible_to(user)
    end
  end
end
