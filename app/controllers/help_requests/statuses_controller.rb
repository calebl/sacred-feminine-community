module HelpRequests
  class StatusesController < ApplicationController
    before_action :authenticate_user!

    def update
      @help_request = HelpRequest.find(params[:help_request_id])
      authorize @help_request, :update?

      @help_request.update!(status: params[:status])
      redirect_to help_request_path(@help_request), notice: "Request marked as #{@help_request.status}."
    end
  end
end
