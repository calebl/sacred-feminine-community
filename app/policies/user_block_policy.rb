class UserBlockPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present? && record.blocker == user
  end

  def destroy?
    record.blocker == user
  end
end
