class GroupPostPolicy < ApplicationPolicy
  def show?
    record.group.can_participate?(user)
  end

  def create?
    record.group.can_participate?(user)
  end

  def update?
    record.user == user
  end

  def destroy?
    user.admin? || record.user == user
  end

  def pin?
    user.admin? || (record.group.member?(user) && record.group.creator?(user))
  end

  class Scope < ApplicationPolicy::Scope
    # Group access is already enforced by the controller before a group's posts
    # are loaded, so the scope's job here is to drop content hidden by a block
    # in either direction. Routing the feed through policy_scope means callers
    # can't forget the block filter.
    def resolve
      scope.visible_to(user)
    end
  end
end
