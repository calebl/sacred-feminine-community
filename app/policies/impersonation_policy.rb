class ImpersonationPolicy < ApplicationPolicy
  def create?
    user.admin? && Rails.env.local?
  end

  def destroy?
    Rails.env.local?
  end
end
