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

  test "user can remove avatar" do
    user = users(:attendee)
    user.avatar.attach(
      io: file_fixture("avatar.png").open,
      filename: "avatar.png",
      content_type: "image/png"
    )
    assert user.avatar.attached?

    sign_in user
    patch profile_path(user), params: {
      user: { name: user.name, remove_avatar: "1" }
    }
    assert_redirected_to profile_path(user)
    assert_not user.reload.avatar.attached?
  end

  test "edit profile page includes image cropper for avatar" do
    sign_in users(:attendee)
    get edit_profile_path(users(:attendee))
    assert_response :success
    assert_select "[data-controller='image-cropper']" do
      assert_select "[data-image-cropper-aspect-ratio-value='1']"
      assert_select "[data-image-cropper-target='fileInput']"
      assert_select "[data-image-cropper-target='cropperWrap']"
      assert_select "[data-image-cropper-target='preview']"
    end
  end

  test "update with invalid params re-renders edit" do
    sign_in users(:attendee)
    patch profile_path(users(:attendee)), params: {
      user: { name: "" }
    }
    assert_response :unprocessable_entity
  end

  test "profile shows cohorts the user belongs to" do
    sign_in users(:admin)
    get profile_path(users(:attendee))
    assert_response :success
    assert_select "h2", text: "Cohorts"
    assert_select "h2", text: cohorts(:kabul_retreat).name
  end

  test "profile cohorts are clickable for users with access" do
    sign_in users(:admin)
    get profile_path(users(:attendee))
    assert_select "a[href=?]", cohort_path(cohorts(:kabul_retreat)), text: /#{cohorts(:kabul_retreat).name}/
  end

  test "profile cohorts are not clickable for users without access" do
    sign_in users(:attendee_two)
    get profile_path(users(:attendee))
    assert_select "a[href=?]", cohort_path(cohorts(:kabul_retreat)), count: 0
    assert_select "h2", text: cohorts(:kabul_retreat).name
  end

  test "profile hides cohorts section when user has no cohorts" do
    sign_in users(:admin)
    get profile_path(users(:attendee_two))
    assert_response :success
    assert_select "h2", text: "Cohorts", count: 0
  end

  test "user can update dm_privacy setting" do
    user = users(:attendee)
    sign_in user
    patch profile_path(user), params: {
      user: { name: user.name, dm_privacy: "nobody" }
    }
    assert_redirected_to profile_path(user)
    assert_equal "nobody", user.reload.dm_privacy
  end

  test "profile shows send message button when recipient allows DMs" do
    sign_in users(:admin)
    user = users(:attendee)
    user.update_column(:dm_privacy, 2) # everyone
    get profile_path(user)
    assert_select "button", text: "Send Message"
  end

  test "profile hides send message button when recipient blocks DMs" do
    sign_in users(:attendee_two)
    user = users(:attendee)
    user.update_column(:dm_privacy, 0) # nobody
    get profile_path(user)
    assert_select "button", text: "Send Message", count: 0
  end

  test "profile shows send message button for admin even when recipient blocks DMs" do
    sign_in users(:admin)
    user = users(:attendee)
    user.update_column(:dm_privacy, 0) # nobody
    get profile_path(user)
    assert_select "button", text: "Send Message"
  end

  test "edit profile displays dm_privacy radio buttons" do
    sign_in users(:attendee)
    get edit_profile_path(users(:attendee))
    assert_response :success
    assert_select "input[type=radio][name='user[dm_privacy]']", count: 3
  end

  test "edit profile shows admin note when dm_privacy is nobody" do
    user = users(:attendee)
    user.update_column(:dm_privacy, 0) # nobody
    sign_in user
    get edit_profile_path(user)
    assert_select "p", text: /admins can still send you messages/
  end

  test "edit profile hides admin note when dm_privacy is not nobody" do
    user = users(:attendee)
    user.update_column(:dm_privacy, 2) # everyone
    sign_in user
    get edit_profile_path(user)
    assert_select "p", text: /admins can still send you messages/, count: 0
  end

  test "edit profile hides dm_privacy radios for admin and shows explanation" do
    sign_in users(:admin)
    get edit_profile_path(users(:admin))
    assert_response :success
    assert_select "input[type=radio][name='user[dm_privacy]']", count: 0
    assert_select "p", text: /As an admin, all community members can message you/
  end
end
