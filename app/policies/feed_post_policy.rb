class FeedPostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def destroy?
    user.admin? || record.user == user
  end

  def pin?
    user.admin?
  end
end
