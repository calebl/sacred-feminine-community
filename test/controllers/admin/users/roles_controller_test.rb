require "test_helper"

class Admin::Users::RolesControllerTest < ActionDispatch::IntegrationTest
  test "admin can promote attendee to admin" do
    sign_in users(:admin)
    attendee = users(:attendee)
    assert attendee.attendee?

    patch admin_user_role_path(attendee)
    assert attendee.reload.admin?
    assert_redirected_to admin_dashboard_path
    assert_match "admin", flash[:notice]
  end

  test "admin can demote admin to attendee" do
    sign_in users(:admin)
    other_admin = users(:attendee_two)
    other_admin.update!(role: :admin)

    patch admin_user_role_path(other_admin)
    assert other_admin.reload.attendee?
    assert_redirected_to admin_dashboard_path
    assert_match "attendee", flash[:notice]
  end

  test "admin cannot change their own role" do
    admin = users(:admin)
    sign_in admin

    patch admin_user_role_path(admin)
    assert admin.reload.admin?
    assert_redirected_to admin_dashboard_path
    assert_equal "You cannot change your own role.", flash[:alert]
  end

  test "attendee cannot change user roles" do
    sign_in users(:attendee)
    patch admin_user_role_path(users(:attendee_two))
    assert users(:attendee_two).reload.attendee?
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected to sign in" do
    patch admin_user_role_path(users(:attendee))
    assert_redirected_to new_user_session_path
  end
end
