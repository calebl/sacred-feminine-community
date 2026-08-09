class UserPolicy < ApplicationPolicy
  def show_profile?
    true
  end

  def edit_profile?
    user == record
  end

  def update_profile?
    user == record
  end

  class Scope < ApplicationPolicy::Scope
    # Hide users whose content is hidden from this one, in either direction: a
    # block by either party, or a cohort gender preference on either side.
    def resolve
      scope.kept.where.not(id: user.hidden_content_user_ids)
    end
  end
end
