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
end
