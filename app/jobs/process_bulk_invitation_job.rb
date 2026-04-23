class ProcessBulkInvitationJob < ApplicationJob
  queue_as :default

  def perform(bulk_invitation_id, emails:, inviter_id:)
    bulk_invitation = BulkInvitation.find_by(id: bulk_invitation_id)
    return unless bulk_invitation

    inviter = User.find_by(id: inviter_id)
    return unless inviter

    cohort = bulk_invitation.cohort

    emails.each do |email|
      existing = User.find_by(email: email)

      if existing
        if existing.invitation_accepted_at? || existing.invitation_token.blank?
          cohort.cohort_memberships.find_or_create_by(user: existing)
          bulk_invitation.increment!(:skipped_count)
        else
          existing_cohort_ids = existing.invited_cohort_ids || []
          existing.update(
            invited_cohort_ids: (existing_cohort_ids.map(&:to_i) | [ cohort.id ]),
            bulk_invitation: bulk_invitation
          )
          existing.invite!(inviter)
          bulk_invitation.increment!(:sent_count)
        end
      else
        user = User.invite!(
          { email: email, name: email.split("@").first.titleize, invited_cohort_ids: [ cohort.id ], bulk_invitation: bulk_invitation },
          inviter
        )
        if user.errors.empty?
          bulk_invitation.increment!(:sent_count)
        else
          bulk_invitation.increment!(:failed_count)
        end
      end
    end
  end
end
