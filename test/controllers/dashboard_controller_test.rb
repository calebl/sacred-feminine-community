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

  test "dashboard displays feed by default" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "h3", text: "Posts"
  end

  test "members panel hides location when show_on_map is false" do
    sign_in users(:attendee)
    get authenticated_root_path(tab: "members")
    assert_response :success
    # attendee_two has show_on_map: false, city: Tokyo, country: Japan
    card = css_select("a[data-name='Sarah Member']").first
    assert card, "Expected to find member card for Sarah Member"
    assert_no_match "Tokyo", card.to_s
    assert_no_match "Japan", card.to_s
  end

  test "members panel shows location when show_on_map is true" do
    sign_in users(:attendee)
    get authenticated_root_path(tab: "members")
    assert_response :success
    # admin has show_on_map: true, city: Los Angeles
    card = css_select("a[data-name='Admin User']").first
    assert card, "Expected to find member card for Admin User"
    assert_match "Los Angeles", card.to_s
  end

  test "unauthenticated user is redirected to sign in" do
    get authenticated_root_path
    assert_redirected_to new_user_session_path
  end

  test "dashboard sidebar displays user cohorts" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_select "h3", text: "My Cohorts"
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
