require "test_helper"

class Admin::BulkInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "admin can access bulk invitation form" do
    sign_in users(:admin)
    get new_admin_bulk_invitation_path
    assert_response :success
    assert_select "select[name='cohort_id']"
    assert_select "textarea[name='emails']"
    assert_select "textarea[name='invitation_message']"
  end

  test "attendee cannot access bulk invitation form" do
    sign_in users(:attendee)
    get new_admin_bulk_invitation_path
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to sign in" do
    get new_admin_bulk_invitation_path
    assert_redirected_to new_user_session_path
  end

  test "admin can submit bulk invite and creates bulk invitation record" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    assert_difference "BulkInvitation.count" do
      post admin_bulk_invitations_path, params: {
        cohort_id: cohort.id,
        emails: "bulk1@example.com\nbulk2@example.com\nbulk3@example.com",
        locked_cohort: "1"
      }
    end

    assert_redirected_to cohort_path(cohort)
    assert_match "3 invitation(s)", flash[:notice]
    assert_match cohort.name, flash[:notice]
  end

  test "bulk invite enqueues ProcessBulkInvitationJob" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    assert_enqueued_with(job: ProcessBulkInvitationJob) do
      post admin_bulk_invitations_path, params: {
        cohort_id: cohort.id,
        emails: "job1@example.com\njob2@example.com"
      }
    end
  end

  test "bulk invite stores custom message on BulkInvitation" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "message-test@example.com",
      invitation_message: "Welcome to our retreat!"
    }

    bulk_invitation = BulkInvitation.last
    assert_equal "Welcome to our retreat!", bulk_invitation.message
    assert_equal cohort, bulk_invitation.cohort
    assert_equal users(:admin), bulk_invitation.invited_by
  end

  test "bulk invite without custom message stores nil message" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "no-message@example.com"
    }

    assert_nil BulkInvitation.last.message
  end

  test "bulk invite with empty emails shows error" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    assert_no_difference "BulkInvitation.count" do
      post admin_bulk_invitations_path, params: {
        cohort_id: cohort.id,
        emails: ""
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Please enter at least one email address.", flash[:alert]
  end

  test "bulk invite with empty emails preserves locked cohort" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "",
      locked_cohort: "1"
    }

    assert_response :unprocessable_entity
    assert_select "input[type='hidden'][name='cohort_id'][value='#{cohort.id}']"
    assert_select "select[name='cohort_id']", count: 0
  end

  test "bulk invite with empty emails preserves cohort select" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: ""
    }

    assert_response :unprocessable_entity
    assert_select "select[name='cohort_id']"
    assert_select "input[type='hidden'][name='cohort_id']", count: 0
  end

  test "bulk invite filters invalid email formats before enqueuing" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    assert_enqueued_with(job: ProcessBulkInvitationJob) do
      post admin_bulk_invitations_path, params: {
        cohort_id: cohort.id,
        emails: "valid@example.com\nnot-an-email\nalso invalid"
      }
    end

    assert_match "1 invitation(s)", flash[:notice]
  end

  test "bulk invite deduplicates emails" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "dupe@example.com\ndupe@example.com"
    }

    assert_match "1 invitation(s)", flash[:notice]
  end

  test "bulk invite parses comma-separated emails" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "comma1@example.com, comma2@example.com"
    }

    assert_match "2 invitation(s)", flash[:notice]
  end

  test "bulk invite parses semicolon-separated emails" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "semi1@example.com; semi2@example.com"
    }

    assert_match "2 invitation(s)", flash[:notice]
  end

  test "attendee cannot create bulk invitations" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    assert_no_difference "BulkInvitation.count" do
      post admin_bulk_invitations_path, params: {
        cohort_id: cohort.id,
        emails: "unauthorized@example.com"
      }
    end

    assert_redirected_to root_path
  end

  test "bulk invitation form locks cohort when cohort_id is provided" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)
    get new_admin_bulk_invitation_path(cohort_id: cohort.id)
    assert_response :success
    assert_select "input[type='hidden'][name='cohort_id'][value='#{cohort.id}']"
    assert_select "input[type='hidden'][name='locked_cohort'][value='1']"
    assert_select "select[name='cohort_id']", count: 0
    assert_select "p", text: cohort.name
  end

  test "bulk invitation form defaults message to previous bulk invitation message" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)
    BulkInvitation.create!(cohort: cohort, invited_by: users(:admin), message: "Welcome to our retreat!")

    get new_admin_bulk_invitation_path(cohort_id: cohort.id)
    assert_response :success
    assert_select "textarea[name='invitation_message']", text: "Welcome to our retreat!"
  end

  test "bulk invitation form shows cohort select without cohort_id param" do
    sign_in users(:admin)
    get new_admin_bulk_invitation_path
    assert_response :success
    assert_select "select[name='cohort_id']"
    assert_select "input[type='hidden'][name='cohort_id']", count: 0
  end

  test "bulk invite redirects to cohort path when locked_cohort is present" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "locked@example.com",
      locked_cohort: "1"
    }

    assert_redirected_to cohort_path(cohort)
  end

  test "bulk invite defaults to admin dashboard without locked_cohort" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)

    post admin_bulk_invitations_path, params: {
      cohort_id: cohort.id,
      emails: "default@example.com"
    }

    assert_redirected_to admin_dashboard_path
  end
end
