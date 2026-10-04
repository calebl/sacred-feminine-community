class DirectMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    authorize @conversation, :show?

    if @conversation.closed_for?(current_user)
      redirect_to conversations_path, alert: "This conversation is no longer available."
      return
    end

    # Starting a conversation is gated in ConversationsController; an existing
    # thread is gated here, or a block or cohort gender preference set after
    # the thread began would let new messages keep arriving.
    unreachable = @conversation.unreachable_recipients(current_user)
    if unreachable.any?
      names = unreachable.map(&:name).join(", ")
      redirect_to @conversation,
        alert: "#{names} #{unreachable.size == 1 ? 'is' : 'are'} no longer receiving your messages."
      return
    end

    @message = @conversation.direct_messages.build(message_params)
    @message.sender = current_user

    if @message.save
      @conversation.touch
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @conversation }
      end
    else
      redirect_to @conversation, alert: "Message could not be sent."
    end
  end

  private

  def message_params
    params.require(:direct_message).permit(:body)
  end
end
