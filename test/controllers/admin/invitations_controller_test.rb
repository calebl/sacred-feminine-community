require "test_helper"

class Admin::InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "admin can access invitation form" do
    sign_in users(:admin)
    get new_user_invitation_path
    assert_response :success
  end

  test "attendee cannot access invitation form" do
    sign_in users(:attendee)
    get new_user_invitation_path
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get new_user_invitation_path
    assert_redirected_to new_user_session_path
  end

  test "admin can send invitation" do
    sign_in users(:admin)
    assert_difference "User.count" do
      post user_invitation_path, params: {
        user: { email: "newmember@example.com", name: "New Member" }
      }
    end
    assert_redirected_to admin_dashboard_path

    invited = User.find_by(email: "newmember@example.com")
    assert_not_nil invited
    assert_not_nil invited.invitation_token
    assert_equal "New Member", invited.name
  end

  test "invitation email is enqueued for async delivery" do
    sign_in users(:admin)
    assert_enqueued_emails 1 do
      post user_invitation_path, params: {
        user: { email: "async@example.com", name: "Async Test" }
      }
    end
  end

  test "attendee cannot send invitation" do
    sign_in users(:attendee)
    assert_no_difference "User.count" do
      post user_invitation_path, params: {
        user: { email: "newmember@example.com", name: "New Member" }
      }
    end
    assert_redirected_to root_path
  end

  test "invalid invitation re-renders form" do
    sign_in users(:admin)
    assert_no_difference "User.count" do
      post user_invitation_path, params: {
        user: { email: "", name: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "unauthenticated user can access invitation acceptance page" do
    user = User.invite!({ email: "accept-test@example.com", name: "Accept Test" }, users(:admin))
    raw_token = user.raw_invitation_token

    get accept_user_invitation_path(invitation_token: raw_token)
    assert_response :success
  end

  test "unauthenticated user can accept invitation and set password" do
    user = User.invite!({ email: "accept-test2@example.com", name: "Accept Test" }, users(:admin))
    raw_token = user.raw_invitation_token

    put user_invitation_path, params: {
      user: {
        invitation_token: raw_token,
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    user.reload
    assert user.invitation_accepted_at.present?
    assert_response :redirect
  end

  test "admin can create invitation via copy link and get JSON response" do
    sign_in users(:admin)
    assert_difference "User.count" do
      post user_invitation_path, params: {
        user: { email: "copylink@example.com", name: "Copy Link User" },
        delivery_method: "link"
      }, headers: { "Accept" => "application/json" }
    end
    assert_response :success

    json = JSON.parse(response.body)
    assert json["url"].include?("invitation_token=")
  end

  test "copy link delivery method does not send email" do
    sign_in users(:admin)
    assert_no_enqueued_emails do
      post user_invitation_path, params: {
        user: { email: "nomail@example.com", name: "No Mail" },
        delivery_method: "link"
      }, headers: { "Accept" => "application/json" }
    end
  end

  test "copy link with invalid params returns JSON errors" do
    sign_in users(:admin)
    post user_invitation_path, params: {
      user: { email: "", name: "" },
      delivery_method: "link"
    }, headers: { "Accept" => "application/json" }
    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert json["errors"].any?
  end

  test "invitation form displays available cohorts" do
    sign_in users(:admin)
    get new_user_invitation_path
    assert_response :success
    assert_select "input[name='user[invited_cohort_ids][]']", count: Cohort.kept.count
  end

  test "admin can send invitation with cohort selections" do
    sign_in users(:admin)
    kabul = cohorts(:kabul_retreat)
    bali = cohorts(:bali_retreat)

    assert_difference "User.count" do
      post user_invitation_path, params: {
        user: { email: "cohort-invite@example.com", name: "Cohort User", invited_cohort_ids: [ kabul.id.to_s, bali.id.to_s ] }
      }
    end

    invited = User.find_by(email: "cohort-invite@example.com")
    assert_equal [ kabul.id, bali.id ].sort, invited.invited_cohort_ids.map(&:to_i).sort
  end

  test "cohort memberships are created when invitation is accepted" do
    kabul = cohorts(:kabul_retreat)
    bali = cohorts(:bali_retreat)

    user = User.invite!({ email: "cohort-accept@example.com", name: "Cohort Accept", invited_cohort_ids: [ kabul.id, bali.id ] }, users(:admin))
    raw_token = user.raw_invitation_token

    assert_difference "CohortMembership.count", 2 do
      put user_invitation_path, params: {
        user: {
          invitation_token: raw_token,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
    end

    user.reload
    assert_includes user.cohorts, kabul
    assert_includes user.cohorts, bali
    assert_empty user.invited_cohort_ids
  end

  test "copy link invitation preserves cohort selections" do
    sign_in users(:admin)
    kabul = cohorts(:kabul_retreat)

    post user_invitation_path, params: {
      user: { email: "link-cohort@example.com", name: "Link Cohort", invited_cohort_ids: [ kabul.id.to_s ] },
      delivery_method: "link"
    }, headers: { "Accept" => "application/json" }
    assert_response :success

    invited = User.find_by(email: "link-cohort@example.com")
    assert_equal [ kabul.id ], invited.invited_cohort_ids.map(&:to_i)
  end

  test "accepted invitation token cannot be reused" do
    user = User.invite!({ email: "reuse@example.com", name: "Reuse Test" }, users(:admin))
    raw_token = user.raw_invitation_token

    put user_invitation_path, params: {
      user: {
        invitation_token: raw_token,
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    get accept_user_invitation_path(invitation_token: raw_token)
    assert_response :redirect
  end
end
