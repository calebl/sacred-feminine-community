require "test_helper"

class BulkInvitationTest < ActiveSupport::TestCase
  test "valid with cohort and invited_by" do
    bulk_invitation = BulkInvitation.new(
      cohort: cohorts(:kabul_retreat),
      invited_by: users(:admin)
    )
    assert bulk_invitation.valid?
  end

  test "invalid without cohort" do
    bulk_invitation = BulkInvitation.new(invited_by: users(:admin))
    assert_not bulk_invitation.valid?
  end

  test "invalid without invited_by" do
    bulk_invitation = BulkInvitation.new(cohort: cohorts(:kabul_retreat))
    assert_not bulk_invitation.valid?
  end

  test "message is optional" do
    bulk_invitation = BulkInvitation.new(
      cohort: cohorts(:kabul_retreat),
      invited_by: users(:admin),
      message: nil
    )
    assert bulk_invitation.valid?
  end

  test "counts default to zero" do
    bulk_invitation = BulkInvitation.create!(
      cohort: cohorts(:kabul_retreat),
      invited_by: users(:admin)
    )
    assert_equal 0, bulk_invitation.sent_count
    assert_equal 0, bulk_invitation.skipped_count
    assert_equal 0, bulk_invitation.failed_count
  end

  test "has many users" do
    bulk_invitation = BulkInvitation.create!(
      cohort: cohorts(:kabul_retreat),
      invited_by: users(:admin),
      message: "Test"
    )
    user = User.invite!(
      { email: "assoc-test@example.com", name: "Assoc Test", bulk_invitation: bulk_invitation },
      users(:admin)
    )
    assert_includes bulk_invitation.users.reload, user
  end

  test "nullifies user references on destroy" do
    bulk_invitation = BulkInvitation.create!(
      cohort: cohorts(:kabul_retreat),
      invited_by: users(:admin)
    )
    user = User.invite!(
      { email: "nullify-test@example.com", name: "Nullify Test", bulk_invitation: bulk_invitation },
      users(:admin)
    )

    bulk_invitation.destroy
    user.reload
    assert_nil user.bulk_invitation_id
  end
end
