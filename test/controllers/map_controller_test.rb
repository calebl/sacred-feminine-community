require "test_helper"

class MapControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can see map" do
    sign_in users(:attendee)
    get map_path
    assert_response :success
  end

  test "unauthenticated user is redirected to sign in" do
    get map_path
    assert_redirected_to new_user_session_path
  end
end
