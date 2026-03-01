class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization
    @conversations = policy_scope(Conversation)
                       .includes(:participants, :conversation_participants, direct_messages: :sender)
                       .order(updated_at: :desc)
  end

  def show
    @conversation = Conversation.find(params[:id])
    authorize @conversation

    unless request.headers["Purpose"] == "prefetch"
      participant = @conversation.conversation_participants.find_by(user: current_user)
      participant&.update(last_read_at: Time.current)
    end

    @messages = @conversation.direct_messages
                              .includes(:sender)
                              .order(created_at: :asc)
    @other_user = @conversation.other_participant(current_user)
  end

  def create
    recipient = User.find(params[:recipient_id])

    if recipient == current_user
      skip_authorization
      redirect_to conversations_path, alert: "Cannot message yourself."
      return
    end

    @conversation = Conversation.between(current_user, recipient)
    authorize @conversation, :show?

    redirect_to @conversation
  end
end
