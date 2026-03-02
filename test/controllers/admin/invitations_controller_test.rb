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
