class ChatMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort

  def create
    authorize @cohort, :post_message?
    @message = @cohort.chat_messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @cohort }
      end
    else
      redirect_to @cohort, alert: "Message could not be sent."
    end
  end

  private

  def set_cohort
    @cohort = Cohort.kept.find(params[:cohort_id])
  end

  def message_params
    params.require(:chat_message).permit(:body)
  end
end
