class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization
    @conversations = policy_scope(Conversation)
                       .includes(:participants, :direct_messages)
                       .order(updated_at: :desc)
  end

  def show
    @conversation = Conversation.find(params[:id])
    authorize @conversation

    participant = @conversation.conversation_participants.find_by(user: current_user)
    participant&.update(last_read_at: Time.current)

    @messages = @conversation.direct_messages
                              .includes(:sender)
                              .order(created_at: :asc)
    @other_user = @conversation.other_participant(current_user)
  end

  def create
    recipient = User.find(params[:recipient_id])
    @conversation = Conversation.between(current_user, recipient)
    authorize @conversation, :show?

    redirect_to @conversation
  end
end
