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

  test "feed shows posts from user cohorts" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
    assert_match posts(:attendee_post).body, response.body
    assert_match "Kabul Retreat 2025", response.body
  end

  test "feed shows posts from user groups" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
    assert_match group_posts(:book_club_pinned).body, response.body
    assert_match "Book Club", response.body
  end

  test "feed shows community feed posts" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
    assert_match feed_posts(:public_post).body, response.body
    assert_match "Community Feed", response.body
  end

  test "feed shows visibility labels" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
    assert_match "Visible to All members", response.body
    assert_match "Visible to Kabul Retreat 2025 members", response.body
    assert_match "Visible to Book Club members", response.body
  end

  test "feed does not show posts from cohorts user is not a member of" do
    user = users(:attendee_two)
    sign_in user
    get authenticated_root_path
    assert_response :success
    # attendee_two is not in any cohort, so should not see cohort posts
    assert_no_match posts(:attendee_post).body, response.body
  end
end
