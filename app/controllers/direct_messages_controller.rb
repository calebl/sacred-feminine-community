class DirectMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    authorize @conversation, :show?

    @message = Conversation.send_message(
      from: current_user,
      conversation: @conversation,
      body: message_params[:body]
    )

    if @message.persisted?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @conversation }
      end
    elsif @message.errors.added?(:base, :conversation_closed)
      redirect_to conversations_path, alert: @message.errors.full_messages.first
    elsif @message.errors.added?(:base, :recipients_unreachable)
      redirect_to @conversation, alert: @message.errors.full_messages.first
    else
      redirect_to @conversation, alert: "Message could not be sent."
    end
  end

  private

  def message_params
    params.require(:direct_message).permit(:body)
  end
end
