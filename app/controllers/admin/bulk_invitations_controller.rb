module Admin
  class BulkInvitationsController < ApplicationController
    before_action :authenticate_user!

    def new
      authorize [ :admin, :bulk_invitation ]
      if params[:cohort_id].present?
        @locked_cohort = Cohort.kept.find(params[:cohort_id])
      else
        @cohorts = Cohort.kept.order(:retreat_start_date)
      end
    end

    def create
      authorize [ :admin, :bulk_invitation ]
      @cohort = Cohort.kept.find(params[:cohort_id])

      emails = parse_emails(params[:emails])

      if emails.empty?
        @locked_cohort = @cohort
        @cohorts = Cohort.kept.order(:retreat_start_date) unless @locked_cohort
        flash.now[:alert] = "Please enter at least one email address."
        return render :new, status: :unprocessable_entity
      end

      bulk_invitation = BulkInvitation.create!(
        cohort: @cohort,
        invited_by: current_user,
        message: params[:invitation_message].presence
      )

      ProcessBulkInvitationJob.perform_later(
        bulk_invitation.id,
        emails: emails,
        inviter_id: current_user.id
      )

      redirect_to safe_return_path, notice: "Sending #{emails.size} invitation(s) for #{@cohort.name}."
    end

    private

    def parse_emails(raw)
      return [] if raw.blank?

      raw.split(/[\s,;]+/).map(&:strip).select { |e| e.match?(URI::MailTo::EMAIL_REGEXP) }.uniq
    end

    def safe_return_path
      return_to = params[:return_to]
      return_to.present? && return_to.start_with?("/") ? return_to : admin_dashboard_path
    end
  end
end
