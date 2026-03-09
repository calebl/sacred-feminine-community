class HelpRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_sidebar
  layout "dashboard"

  def index
    @help_requests = policy_scope(HelpRequest).includes(:user).newest_first
    authorize HelpRequest
  end

  def show
    @help_request = HelpRequest.find(params[:id])
    authorize @help_request
    @replies = @help_request.help_request_replies.includes(:user).order(:created_at)
    @reply = HelpRequestReply.new
  end

  def new
    @help_request = HelpRequest.new
    authorize @help_request
  end

  def create
    @help_request = current_user.help_requests.build(help_request_params)
    authorize @help_request

    if @help_request.save
      redirect_to help_request_path(@help_request), notice: "Your help request has been submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def load_sidebar
    @sidebar_cohorts = current_user.cohorts.order(retreat_start_date: :desc)
    @sidebar_groups = current_user.groups.order(:name)
  end

  def help_request_params
    params.require(:help_request).permit(:subject, :body)
  end
end
