class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    skip_authorization

    @conversations = policy_scope(Conversation)
                       .includes(:participants, :conversation_participants, direct_messages: :sender)
                       .order(updated_at: :desc)

    @cohorts = policy_scope(Cohort)
                 .includes(:cohort_memberships, :chat_messages)
                 .order(:name)

    @unread_conversations = @conversations.select { |c| c.unread_count(current_user) > 0 }
    @unread_cohorts = @cohorts.select { |c| c.unread_count(current_user) > 0 }
  end
end
