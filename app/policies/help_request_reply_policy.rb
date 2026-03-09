class HelpRequestReplyPolicy < ApplicationPolicy
  def create?
    user.admin? || record.help_request.user == user
  end
end
