class ApiTokenPolicy < ApplicationPolicy
  def index?
    true
  end

  def destroy?
    record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end
