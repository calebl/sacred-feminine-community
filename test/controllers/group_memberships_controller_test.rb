require "test_helper"

class GroupMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "non-member can join a group" do
    sign_in users(:attendee_two)
    group = groups(:book_club)

    assert_difference "GroupMembership.count" do
      post group_group_membership_path(group)
    end
    assert_redirected_to group_path(group)
    assert group.member?(users(:attendee_two))
  end

  test "joining from the index returns a turbo stream with the member checkmark" do
    sign_in users(:attendee_two)
    group = groups(:book_club)

    assert_difference "GroupMembership.count" do
      post group_group_membership_path(group),
           params: { context: "index" },
           as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match "You&#39;re a member", response.body
    assert group.member?(users(:attendee_two))
  end

  test "already a member cannot join again" do
    sign_in users(:attendee)
    group = groups(:book_club)

    assert_no_difference "GroupMembership.count" do
      post group_group_membership_path(group)
    end
    assert_redirected_to root_path
  end

  test "member can leave a group" do
    sign_in users(:admin)
    group = groups(:book_club)

    assert_difference "GroupMembership.count", -1 do
      delete group_group_membership_path(group)
    end
    assert_redirected_to groups_path
    assert_not group.member?(users(:admin))
  end

  test "creator can leave their group" do
    sign_in users(:attendee)
    group = groups(:book_club)

    assert_difference "GroupMembership.count", -1 do
      delete group_group_membership_path(group)
    end
    assert_redirected_to groups_path
    assert_not group.member?(users(:attendee))
  end

  test "unauthenticated user cannot join" do
    group = groups(:book_club)
    assert_no_difference "GroupMembership.count" do
      post group_group_membership_path(group)
    end
    assert_redirected_to new_user_session_path
  end
end
