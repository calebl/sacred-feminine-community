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
end
