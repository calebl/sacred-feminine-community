class CohortPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.member?(user)
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def post_message?
    record.member?(user)
  end

  def manage_members?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:cohort_memberships)
             .where(cohort_memberships: { user_id: user.id })
      end
    end
  end
end
