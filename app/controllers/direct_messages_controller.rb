class DirectMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    authorize @conversation, :show?

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
