require "test_helper"

class Admin::FeaturesControllerTest < ActionDispatch::IntegrationTest
  test "admin can view features page" do
    sign_in users(:admin)
    get admin_features_path
    assert_response :success
    assert_select "h1", text: "Platform Features"
  end

  test "features page renders markdown content" do
    sign_in users(:admin)
    get admin_features_path
    assert_select "h2", text: "Authentication & User Management"
  end

  test "attendee cannot access features page" do
    sign_in users(:attendee)
    get admin_features_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get admin_features_path
    assert_redirected_to new_user_session_path
  end
end
