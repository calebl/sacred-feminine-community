class DirectMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    authorize @conversation, :show?

    other_users = @conversation.other_participants(current_user)
    if other_users.all?(&:discarded?)
      redirect_to conversations_path, alert: "This conversation is no longer available."
      return
    end

    # Starting a conversation is gated in ConversationsController; an existing
    # thread has to be gated too, or a block or cohort gender preference set
    # after the thread began would let new messages keep arriving. Deliberately
    # narrower than accepts_direct_messages_from?: a recipient who later sets
    # dm_privacy to "nobody" is closing their door to new conversations, not
    # walking out of the ones they are already in.
    unreachable = other_users.select { |recipient| recipient.hides_content_from?(current_user) }
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
