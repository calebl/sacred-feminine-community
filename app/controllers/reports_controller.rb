class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report

  def new
    authorize @report, :create?
  end

  def create
    authorize @report
    help_request = @report.submit
    redirect_to help_request_path(help_request),
                notice: "Thank you. Your report has been sent to the community admins."
  end

  private

  def set_report
    reportable = ContentReport.find_reportable(report_params[:reportable_type], report_params[:reportable_id])
    raise ActiveRecord::RecordNotFound unless reportable

    @report = ContentReport.new(reporter: current_user, reportable: reportable, reason: report_params[:reason])
  end

  def report_params
    params.fetch(:report, params).permit(:reportable_type, :reportable_id, :reason)
  end
end
