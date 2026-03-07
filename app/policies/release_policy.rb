class ReleasePolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
