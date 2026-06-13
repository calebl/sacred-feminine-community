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
    # Blocking is mutual for visibility, so hide users on either side of a block
    # (people this user blocked and people who blocked this user).
    def resolve
      scope.kept.where.not(id: user.hidden_content_user_ids)
    end
  end
end
