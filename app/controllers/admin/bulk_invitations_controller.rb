module Admin
  class BulkInvitationsController < ApplicationController
    before_action :authenticate_user!

    def new
      authorize [ :admin, :bulk_invitation ]
      if params[:cohort_id].present?
        @locked_cohort = Cohort.kept.find(params[:cohort_id])
        @previous_message = @locked_cohort.bulk_invitations.order(created_at: :desc).pick(:message) || default_message
      else
        @cohorts = Cohort.kept.order(:retreat_start_date)
        @previous_message = default_message
      end
    end

    def create
      authorize [ :admin, :bulk_invitation ]
      @cohort = Cohort.kept.find(params[:cohort_id])
      @locked_cohort = @cohort if params[:locked_cohort].present?

      emails = parse_emails(params[:emails])

      if emails.empty?
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

      redirect_to after_create_path, notice: "Sending #{emails.size} invitation(s) for #{@cohort.name}."
    end

    private

    def after_create_path
      @locked_cohort ? cohort_path(@locked_cohort) : admin_dashboard_path
    end

    def parse_emails(raw)
      return [] if raw.blank?

      raw.split(/[\s,;]+/).map(&:strip).select { |e| e.match?(URI::MailTo::EMAIL_REGEXP) }.uniq
    end

    def default_message
      "You are invited to make an account on our new Sacred Feminine Community platform. If you would like to join, click the link below. If you do not wish to join, please ignore this email."
    end
  end
end
