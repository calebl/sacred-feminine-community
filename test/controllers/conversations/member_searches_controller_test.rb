require "test_helper"

class Conversations::MemberSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
  end

  test "index requires authentication" do
    get conversations_member_searches_path(q: "Jane")
    assert_redirected_to new_user_session_path
  end

  test "index returns results matching query" do
    sign_in @admin
    get conversations_member_searches_path(q: "Jane")
    assert_response :success
    assert_match "Jane Attendee", response.body
  end

  test "index excludes current user from results" do
    sign_in @admin
    get conversations_member_searches_path(q: "Admin")
    assert_response :success
    refute_match "Admin User", response.body
  end

  test "index returns empty when no query" do
    sign_in @admin
    get conversations_member_searches_path
    assert_response :success
    refute_match "Jane", response.body
  end

  test "index returns no match message when query has no results" do
    sign_in @admin
    get conversations_member_searches_path(q: "ZZZZNONEXISTENT")
    assert_response :success
    assert_match "No members found", response.body
  end

  test "index shows selectable button for users accepting DMs" do
    @attendee.update_column(:dm_privacy, 2)
    sign_in @attendee_two
    get conversations_member_searches_path(q: "Jane")
    assert_response :success
    assert_match "data-user-id", response.body
  end

  test "index shows not-accepting indicator when DMs are blocked" do
    @attendee.update_column(:dm_privacy, 0)
    sign_in @attendee_two
    get conversations_member_searches_path(q: "Jane")
    assert_response :success
    assert_match "Not accepting DMs", response.body
  end

  test "index does not return pending invitations" do
    sign_in @admin
    get conversations_member_searches_path(q: "Pending")
    assert_response :success
    refute_match "Pending User", response.body
  end
end
