class NotificationPolicy < ApplicationPolicy
  def update?
    user == record.user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end
end
