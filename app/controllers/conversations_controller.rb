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
      Mention.unread
             .where(user: current_user, mentionable_type: "DirectMessage")
             .where(mentionable_id: @conversation.direct_messages.select(:id))
             .update_all(read_at: Time.current)
      Notification.unread.where(user: current_user, event_type: "mention", notifiable_type: "DirectMessage")
                  .where(notifiable_id: @conversation.direct_messages.select(:id))
                  .update_all(read_at: Time.current)
      Notification.unread.where(user: current_user, event_type: "direct_message",
                                group_key: "conversation:#{@conversation.id}")
                  .update_all(read_at: Time.current)
    end

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

    blocked = recipients.reject { |r| r.accepts_direct_messages_from?(current_user) }
    if blocked.any?
      skip_authorization
      names = blocked.map(&:name).join(", ")
      redirect_back fallback_location: new_conversation_path,
        alert: "#{names} #{blocked.size == 1 ? 'is' : 'are'} not accepting direct messages."
      return
    end

    @conversation = Conversation.between([ current_user ] + recipients.to_a)
    authorize @conversation, :show?
    @conversation.send_message(from: current_user, body: params[:body])

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
