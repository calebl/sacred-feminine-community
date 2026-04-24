module Admin
  class BulkInvitationPolicy < ApplicationPolicy
    def new?
      user.admin?
    end

    def create?
      user.admin?
    end
  end
end
