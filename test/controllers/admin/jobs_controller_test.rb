require "test_helper"

class Admin::JobsControllerTest < ActionDispatch::IntegrationTest
  test "admin can access solid queue dashboard" do
    sign_in users(:admin)
    get "/admin/jobs"
    assert_response :success
  end

  test "attendee cannot access solid queue dashboard" do
    sign_in users(:attendee)
    get "/admin/jobs"
    assert_response :not_found
  end

  test "unauthenticated user cannot access solid queue dashboard" do
    get "/admin/jobs"
    assert_redirected_to "/users/sign_in"
  end
end
