class GroupChatMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group

  def create
    authorize @group, :post_message?
    @message = @group.group_chat_messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @group }
      end
    else
      redirect_to @group, alert: "Message could not be sent."
    end
  end

  private

  def set_group
    @group = Group.kept.find(params[:group_id])
  end

  def message_params
    params.require(:group_chat_message).permit(:body)
  end
end
