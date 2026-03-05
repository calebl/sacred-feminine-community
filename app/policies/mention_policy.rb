class MentionPolicy < ApplicationPolicy
  def show?
    user == record.user || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end
