module Account
  class UserPolicy < ApplicationPolicy
    def update_email?
      user == record
    end

    def update_password?
      user == record
    end

    # The community always keeps at least one admin.
    def destroy_account?
      user == record && (!record.admin? || User.admin.kept.where.not(id: record.id).exists?)
    end
  end
end
