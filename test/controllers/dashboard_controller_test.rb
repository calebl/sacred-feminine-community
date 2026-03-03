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

  test "map container has z-index below navbar to prevent overlap" do
    sign_in users(:attendee)
    get authenticated_root_path

    navbar = css_select("nav.sticky.top-0").first
    map_panel = css_select("[data-panel-name='map']").first

    navbar_z = navbar["class"][/\bz-(\d+)\b/, 1].to_i
    map_z = map_panel["class"][/\bz-(\d+)\b/, 1].to_i

    assert map_z < navbar_z,
      "Map z-index (#{map_z}) must be less than navbar z-index (#{navbar_z})"
  end

  test "dashboard displays member directory" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "[data-panel-name='members']" do
      assert_select "[data-member-search-target='card']", minimum: 1
      assert_select "a[data-name='Jane Attendee']"
    end
  end

  test "dashboard displays announcements" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "[data-panel-name='announcements']" do
      assert_select "h3", text: "Welcome to the Community"
      assert_select "h3", text: "Old Announcement"
    end
  end

  test "unauthenticated user is redirected to sign in" do
    get authenticated_root_path
    assert_redirected_to new_user_session_path
  end
end
