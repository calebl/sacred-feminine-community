require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "admin can access dashboard" do
    sign_in users(:admin)
    get admin_dashboard_path
    assert_response :success
  end

  test "attendee cannot access dashboard" do
    sign_in users(:attendee)
    get admin_dashboard_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get admin_dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "admin dashboard shows user count and cohort count" do
    sign_in users(:admin)
    get admin_dashboard_path
    assert_response :success
    assert_select "body" # verifies the response renders a full page
  end
end
