require "test_helper"

class Admin::ReleasesControllerTest < ActionDispatch::IntegrationTest
  test "admin can access changelog" do
    sign_in users(:admin)
    get admin_releases_path
    assert_response :success
  end

  test "admin sees releases listed" do
    sign_in users(:admin)
    get admin_releases_path
    assert_select "h2", text: releases(:v2).version
    assert_select "h2", text: releases(:v1).version
  end

  test "attendee cannot access changelog" do
    sign_in users(:attendee)
    get admin_releases_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get admin_releases_path
    assert_redirected_to new_user_session_path
  end
end
