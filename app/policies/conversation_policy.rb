class ConversationPolicy < ApplicationPolicy
  def show?
    record.participants.include?(user)
  end

  def create?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:conversation_participants)
           .where(conversation_participants: { user_id: user.id })
    end
  end
end
