module HelpRequests
  class StatusesController < ApplicationController
    before_action :authenticate_user!

    def update
      @help_request = HelpRequest.find(params[:help_request_id])
      authorize @help_request, :update?

      unless HelpRequest.statuses.key?(params[:status])
        redirect_to help_request_path(@help_request), alert: "Invalid status."
        return
      end

      @help_request.user.with_lock do
        if reopening_duplicate_report?
          redirect_to help_request_path(@help_request),
                      alert: "Another report for this item is already open. Close it before reopening this report."
        else
          @help_request.update!(status: params[:status])
          redirect_to help_request_path(@help_request), notice: "Request marked as #{@help_request.status}."
        end
      end
    end

    private

    def reopening_duplicate_report?
      params[:status] == "open" && @help_request.reportable_type.present? &&
        HelpRequest.open.where(
          user_id: @help_request.user_id,
          reportable_type: @help_request.reportable_type,
          reportable_id: @help_request.reportable_id
        ).where.not(id: @help_request.id).exists?
    end
  end
end
