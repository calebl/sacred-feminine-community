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
      user: { name: "Updated Name", city: "Berlin", state: "Berlin", country: "Germany", show_on_map: true }
    }
    assert_redirected_to profile_path(users(:attendee))

    users(:attendee).reload
    assert_equal "Updated Name", users(:attendee).name
    assert_equal "Berlin", users(:attendee).city
    assert_equal "Berlin", users(:attendee).state
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

  test "shows mini map when user has location and show_on_map" do
    user = users(:admin)
    user.update_columns(latitude: 34.0522, longitude: -118.2437, show_on_map: true)
    sign_in users(:attendee)
    get profile_path(user)
    assert_response :success
    assert_select "[data-controller='profile-map']"
  end

  test "hides mini map when show_on_map is false" do
    user = users(:attendee_two)
    user.update_columns(latitude: 35.6762, longitude: 139.6503)
    sign_in users(:admin)
    get profile_path(user)
    assert_response :success
    assert_select "[data-controller='profile-map']", count: 0
  end

  test "hides mini map when coordinates are missing" do
    user = users(:attendee)
    sign_in users(:admin)
    get profile_path(user)
    assert_response :success
    assert_select "[data-controller='profile-map']", count: 0
  end

  test "update with invalid params re-renders edit" do
    sign_in users(:attendee)
    patch profile_path(users(:attendee)), params: {
      user: { name: "" }
    }
    assert_response :unprocessable_entity
  end
end
