class GroupPostPolicy < ApplicationPolicy
  def show?
    record.group.member?(user)
  end

  def create?
    record.group.member?(user)
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
end
