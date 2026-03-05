require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can see dashboard" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
  end

  test "dashboard displays community map" do
    sign_in users(:attendee)
    get authenticated_root_path(tab: "map")
    assert_select "[data-controller='map']"
  end

  test "dashboard displays member directory" do
    sign_in users(:attendee)
    get authenticated_root_path(tab: "members")
    assert_select "[data-member-search-target='card']", minimum: 1
    assert_select "a[data-name='Jane Attendee']"
  end

  test "dashboard displays announcements by default" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "h3", text: "Welcome to the Community"
    assert_select "h3", text: "Old Announcement"
  end

  test "unauthenticated user is redirected to sign in" do
    get authenticated_root_path
    assert_redirected_to new_user_session_path
  end

  test "dashboard sidebar displays user cohorts" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "h3", text: "Cohorts"
    assert_select "a[href*='cohorts']", minimum: 1
  end

  test "dashboard displays FAQs panel" do
    sign_in users(:attendee)
    get authenticated_root_path(tab: "faqs")
    assert_match(/FAQ/i, response.body)
  end

  test "dashboard displays Groups placeholder" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "h3", text: "Groups"
  end

  test "dashboard uses dashboard layout with sidebar" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "h3", text: "Explore"
  end
end
