class HelpRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.user == user
  end

  def create?
    true
  end

  def update?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
