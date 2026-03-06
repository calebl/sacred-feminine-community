require "test_helper"

class MentionSearchesControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get mention_searches_path, params: { q: "Admin" }
    assert_redirected_to new_user_session_path
  end

  test "returns cohort members matching query" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    get mention_searches_path, params: { q: "Admin", cohort_id: cohort.id }
    assert_response :success
    assert_match "Admin User", response.body
  end

  test "excludes current user from results" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    get mention_searches_path, params: { q: "Jane", cohort_id: cohort.id }
    assert_response :success
    assert_no_match "Jane Attendee", response.body
  end

  test "returns empty for non-member cohort" do
    sign_in users(:attendee_two)
    cohort = cohorts(:kabul_retreat)

    get mention_searches_path, params: { q: "Admin", cohort_id: cohort.id }
    assert_response :success
    assert_no_match "Admin User", response.body
  end

  test "returns group members matching query" do
    sign_in users(:attendee)
    group = groups(:book_club)

    get mention_searches_path, params: { q: "Admin", group_id: group.id }
    assert_response :success
    assert_match "Admin User", response.body
  end

  test "returns conversation participants matching query" do
    sign_in users(:admin)
    conversation = conversations(:admin_attendee_convo)

    get mention_searches_path, params: { q: "Jane", conversation_id: conversation.id }
    assert_response :success
    assert_match "Jane Attendee", response.body
  end

  test "includes non-member admins in cohort mention search" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    get mention_searches_path, params: { q: "Admin Two", cohort_id: cohort.id }
    assert_response :success
    assert_match "Admin Two", response.body
  end

  test "includes non-member admins in group mention search" do
    sign_in users(:attendee)
    group = groups(:book_club)

    get mention_searches_path, params: { q: "Admin Two", group_id: group.id }
    assert_response :success
    assert_match "Admin Two", response.body
  end

  test "allows admin to search mentions in cohort they are not a member of" do
    sign_in users(:admin_two)
    cohort = cohorts(:kabul_retreat)

    get mention_searches_path, params: { q: "Jane", cohort_id: cohort.id }
    assert_response :success
    assert_match "Jane Attendee", response.body
  end

  test "returns all users with no context params" do
    sign_in users(:attendee)
    get mention_searches_path, params: { q: "Admin" }
    assert_response :success
    assert_match "Admin User", response.body
  end

  test "returns empty with blank query" do
    sign_in users(:attendee)
    get mention_searches_path, params: { q: "", cohort_id: cohorts(:kabul_retreat).id }
    assert_response :success
  end
end
