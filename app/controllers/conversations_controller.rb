class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization
    @conversations = policy_scope(Conversation)
                       .joins(:direct_messages)
                       .includes(:participants, :conversation_participants, direct_messages: :sender)
                       .order(updated_at: :desc)
                       .distinct
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

  def new
    skip_authorization
  end

  def create
    recipient = User.kept.find(params[:recipient_id])

    if recipient == current_user
      skip_authorization
      redirect_to conversations_path, alert: "Cannot message yourself."
      return
    end

    unless recipient.accepts_direct_messages_from?(current_user)
      skip_authorization
      redirect_back fallback_location: new_conversation_path, alert: "This member is not accepting direct messages."
      return
    end

    @conversation = Conversation.between(current_user, recipient)
    authorize @conversation, :show?

    if params[:body].present?
      @conversation.direct_messages.create!(sender: current_user, body: params[:body])
      @conversation.touch
    end

    redirect_to @conversation
  end
end
