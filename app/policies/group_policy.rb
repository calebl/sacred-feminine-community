class GroupPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    user.admin? || record.creator?(user)
  end

  def destroy?
    user.admin? || record.creator?(user)
  end

  def join?
    !record.member?(user)
  end

  def leave?
    record.member?(user)
  end

  def post_message?
    record.member?(user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.kept
    end
  end
end
