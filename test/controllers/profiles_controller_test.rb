require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can view any profile" do
    sign_in users(:attendee)
    get profile_path(users(:admin))
    assert_response :success
  end

  test "unauthenticated user is redirected to sign in" do
    get profile_path(users(:admin))
    assert_redirected_to new_user_session_path
  end

  test "user can edit own profile" do
    sign_in users(:attendee)
    get edit_profile_path(users(:attendee))
    assert_response :success
  end

  test "user cannot edit another user profile" do
    sign_in users(:attendee)
    get edit_profile_path(users(:admin))
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "user can update own profile" do
    sign_in users(:attendee)
    patch profile_path(users(:attendee)), params: {
      user: { name: "Updated Name", city: "Berlin", country: "Germany", show_on_map: true }
    }
    assert_redirected_to profile_path(users(:attendee))

    users(:attendee).reload
    assert_equal "Updated Name", users(:attendee).name
    assert_equal "Berlin", users(:attendee).city
    assert_equal "Germany", users(:attendee).country
  end

  test "user cannot update another user profile" do
    sign_in users(:attendee)
    patch profile_path(users(:admin)), params: {
      user: { name: "Hacked" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked", users(:admin).reload.name
  end

  test "update with invalid params re-renders edit" do
    sign_in users(:attendee)
    patch profile_path(users(:attendee)), params: {
      user: { name: "" }
    }
    assert_response :unprocessable_entity
  end
end
