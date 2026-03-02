module Account
  class UserPolicy < ApplicationPolicy
    def update_email?
      user == record
    end

    def update_password?
      user == record
    end
  end
end
