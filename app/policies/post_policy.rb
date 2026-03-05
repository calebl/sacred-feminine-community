class PostPolicy < ApplicationPolicy
  def show?
    user.admin? || record.cohort.member?(user)
  end

  def create?
    user.admin? || record.cohort.member?(user)
  end

  def destroy?
    user.admin? || record.user == user
  end

  def pin?
    user.admin?
  end
end
