module Admin
  module Users
    class UserPolicy < ApplicationPolicy
      def update_role?
        user.admin?
      end
    end
  end
end
