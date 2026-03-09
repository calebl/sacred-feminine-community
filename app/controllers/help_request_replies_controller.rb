class HelpRequestRepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_sidebar
  layout "dashboard"

  def create
    @help_request = HelpRequest.find(params[:help_request_id])
    @reply = @help_request.help_request_replies.build(reply_params.merge(user: current_user))
    authorize @reply

    if @reply.save
      redirect_to help_request_path(@help_request), notice: "Reply sent."
    else
      @replies = @help_request.help_request_replies.includes(:user).order(:created_at)
      render "help_requests/show", status: :unprocessable_entity
    end
  end

  private

  def load_sidebar
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
  end

  def reply_params
    params.require(:help_request_reply).permit(:body)
  end
end
