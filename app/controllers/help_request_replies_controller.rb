class HelpRequestRepliesController < ApplicationController
  before_action :authenticate_user!

  def create
    @help_request = HelpRequest.find(params[:help_request_id])
    @reply = @help_request.help_request_replies.build(reply_params.merge(user: current_user))
    authorize @reply

    if @reply.save
      notify_participants
      redirect_to help_request_path(@help_request), notice: "Reply sent."
    else
      @replies = @help_request.help_request_replies.includes(:user).order(:created_at)
      render "help_requests/show", status: :unprocessable_entity
    end
  end

  private

  def reply_params
    params.require(:help_request_reply).permit(:body)
  end

  def notify_participants
    recipient_ids = if current_user.admin?
      [ @help_request.user_id ]
    else
      @help_request.help_request_replies
        .joins(:user).where(users: { role: :admin })
        .where.not(user_id: current_user.id)
        .distinct.pluck(:user_id)
    end

    recipient_ids.each do |user_id|
      CreateNotificationJob.perform_later(
        user_id: user_id,
        actor_id: current_user.id,
        event_type: "help_request_reply",
        title: "Help Request Reply",
        body: "#{current_user.name} replied to: #{@help_request.subject}",
        path: help_request_path(@help_request),
        notifiable: @help_request
      )
    end
  end
end
