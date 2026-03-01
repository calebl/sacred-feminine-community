require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can see dashboard" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
  end

  test "dashboard displays community map" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "[data-controller='map']"
  end

  test "unauthenticated user is redirected to sign in" do
    get authenticated_root_path
    assert_redirected_to new_user_session_path
  end
end
