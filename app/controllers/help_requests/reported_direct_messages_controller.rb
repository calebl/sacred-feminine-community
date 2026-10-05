module HelpRequests
  class ReportedDirectMessagesController < ApplicationController
    before_action :authenticate_user!

    def show
      @help_request = HelpRequest.find(params[:help_request_id])
      authorize @help_request, policy_class: ReportedDirectMessagePolicy
      @direct_message = @help_request.reportable
    end
  end
end
