require "test_helper"

class ProcessBulkInvitationJobTest < ActiveJob::TestCase
  setup do
    @admin = users(:admin)
    @cohort = cohorts(:kabul_retreat)
    @bulk_invitation = BulkInvitation.create!(
      cohort: @cohort,
      invited_by: @admin,
      message: "Welcome to the retreat!"
    )
  end

  test "invites new users and assigns them to cohort" do
    emails = [ "new1@example.com", "new2@example.com" ]

    assert_difference "User.count", 2 do
      ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: emails, inviter_id: @admin.id)
    end

    @bulk_invitation.reload
    assert_equal 2, @bulk_invitation.sent_count

    emails.each do |email|
      user = User.find_by(email: email)
      assert_not_nil user
      assert_includes user.invited_cohort_ids.map(&:to_i), @cohort.id
      assert_equal @bulk_invitation, user.bulk_invitation
    end
  end

  test "assigns default name from email for new users" do
    ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: [ "jane.doe@example.com" ], inviter_id: @admin.id)

    user = User.find_by(email: "jane.doe@example.com")
    assert_equal "Jane.Doe", user.name
  end

  test "adds existing active users to cohort and increments skipped_count" do
    existing_user = users(:attendee)

    assert_no_difference "User.count" do
      ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: [ existing_user.email ], inviter_id: @admin.id)
    end

    @bulk_invitation.reload
    assert_equal 0, @bulk_invitation.sent_count
    assert_equal 1, @bulk_invitation.skipped_count
    assert existing_user.cohort_memberships.exists?(cohort: @cohort)
  end

  test "resends invitation to pending users and adds cohort" do
    pending_user = users(:pending_invite)

    assert_no_difference "User.count" do
      ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: [ pending_user.email ], inviter_id: @admin.id)
    end

    @bulk_invitation.reload
    assert_equal 1, @bulk_invitation.sent_count
    pending_user.reload
    assert_includes pending_user.invited_cohort_ids.map(&:to_i), @cohort.id
    assert_equal @bulk_invitation, pending_user.bulk_invitation
  end

  test "enqueues invitation emails for new users" do
    emails = [ "email1@example.com", "email2@example.com" ]

    ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: emails, inviter_id: @admin.id)

    @bulk_invitation.reload
    assert_equal 2, @bulk_invitation.sent_count
    assert User.find_by(email: "email1@example.com").invitation_token.present?
    assert User.find_by(email: "email2@example.com").invitation_token.present?
  end

  test "links invited users to the bulk invitation record" do
    ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: [ "linked@example.com" ], inviter_id: @admin.id)

    user = User.find_by(email: "linked@example.com")
    assert_equal @bulk_invitation, user.bulk_invitation
    assert_equal "Welcome to the retreat!", user.bulk_invitation.message
  end

  test "handles missing bulk invitation gracefully" do
    assert_nothing_raised do
      ProcessBulkInvitationJob.perform_now(0, emails: [ "ghost@example.com" ], inviter_id: @admin.id)
    end
  end

  test "handles missing inviter gracefully" do
    assert_nothing_raised do
      ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: [ "ghost@example.com" ], inviter_id: 0)
    end
  end

  test "handles mix of new, existing, and pending users" do
    pending_user = users(:pending_invite)
    existing_user = users(:attendee)
    emails = [ "brand-new@example.com", existing_user.email, pending_user.email ]

    assert_difference "User.count", 1 do
      ProcessBulkInvitationJob.perform_now(@bulk_invitation.id, emails: emails, inviter_id: @admin.id)
    end

    @bulk_invitation.reload
    assert_equal 2, @bulk_invitation.sent_count
    assert_equal 1, @bulk_invitation.skipped_count
  end
end
