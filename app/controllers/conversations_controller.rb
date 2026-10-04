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

    @conversation.mark_as_read_by(current_user) unless request.headers["Purpose"] == "prefetch"

    @messages = @conversation.direct_messages
                              .includes(:sender)
                              .order(created_at: :asc)
    @other_users = @conversation.other_participants(current_user)
  end

  def new
    skip_authorization
  end

  def create
    recipients = resolve_recipients
    return unless recipients

    message = Conversation.send_message(from: current_user, recipients: recipients.to_a, body: params[:body])
    if message.errors.added?(:base, :recipients_refused) ||
        message.errors.added?(:base, :sender_unavailable)
      skip_authorization
      redirect_back fallback_location: new_conversation_path, alert: message.errors.full_messages.first
      return
    end

    @conversation = message.conversation
    authorize @conversation, :show?
    redirect_to @conversation
  end

  private

  def resolve_recipients
    recipient_ids = params[:recipient_ids].present? ? Array(params[:recipient_ids]) : [ params[:recipient_id] ]
    recipients = User.kept.where(id: recipient_ids)

    if recipients.empty?
      skip_authorization
      redirect_to new_conversation_path, alert: "Please select at least one recipient."
      return
    end

    if recipients.map(&:id).sort == [ current_user.id ]
      skip_authorization
      redirect_to conversations_path, alert: "Cannot message yourself."
      return
    end

    recipients.where.not(id: current_user.id)
  end
end
