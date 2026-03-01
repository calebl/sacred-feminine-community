require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  # === Cancel pending invitation (hard delete) ===

  test "admin can cancel a pending invitation" do
    sign_in users(:admin)
    pending_user = users(:pending_invite)
    assert_difference "User.count", -1 do
      delete admin_user_path(pending_user)
    end
    assert_redirected_to admin_dashboard_path
    assert_match "cancelled", flash[:notice]
  end

  # === Soft-delete accepted user ===

  test "admin can remove an accepted user" do
    sign_in users(:admin)
    assert_no_difference "User.count" do
      delete admin_user_path(users(:attendee_two))
    end
    assert users(:attendee_two).reload.discarded?
    assert_redirected_to admin_dashboard_path
    assert_match "removed", flash[:notice]
  end

  test "admin cannot remove themselves" do
    admin = users(:admin)
    sign_in admin
    delete admin_user_path(admin)
    assert_not admin.reload.discarded?
    assert_redirected_to admin_dashboard_path
    assert_equal "You cannot remove yourself.", flash[:alert]
  end

  # === Restore removed user ===

  test "admin can restore a removed user" do
    sign_in users(:admin)
    user = users(:attendee_two)
    user.discard!

    patch admin_user_path(user)
    assert_not user.reload.discarded?
    assert_redirected_to admin_dashboard_path
    assert_match "restored", flash[:notice]
  end

  # === Removed users index ===

  test "admin can view removed users index" do
    sign_in users(:admin)
    users(:attendee_two).discard!

    get admin_users_path
    assert_response :success
    assert_match users(:attendee_two).name, response.body
  end

  test "removed users index is empty when no users are removed" do
    sign_in users(:admin)
    get admin_users_path
    assert_response :success
    assert_match "No removed users", response.body
  end

  # === Authorization ===

  test "attendee cannot remove users" do
    sign_in users(:attendee)
    delete admin_user_path(users(:attendee_two))
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "attendee cannot view removed users" do
    sign_in users(:attendee)
    get admin_users_path
    assert_redirected_to root_path
  end

  test "attendee cannot restore users" do
    sign_in users(:attendee)
    users(:attendee_two).discard!
    patch admin_user_path(users(:attendee_two))
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to sign in for destroy" do
    delete admin_user_path(users(:attendee))
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user is redirected to sign in for index" do
    get admin_users_path
    assert_redirected_to new_user_session_path
  end
end
