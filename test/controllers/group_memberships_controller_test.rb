require "test_helper"

class GroupMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "non-member can join a group" do
    sign_in users.attendee_two
    group = groups.book_club

    assert_difference "GroupMembership.count" do
      post group_group_membership_path(group)
    end
    assert_redirected_to group_path(group)
    assert group.member?(users.attendee_two)
  end

  test "joining from the index removes the card and inserts the group alphabetically in the sidebar" do
    sign_in users.attendee_two
    group = groups.book_club # "Book Club..." sorts before the member's "Reading Group"

    assert_difference "GroupMembership.count" do
      post group_group_membership_path(group),
           params: { context: "index" },
           as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action=?][target=?]", "remove_with_fade",
                  ActionView::RecordIdentifier.dom_id(group)
    # Inserted before the alphabetically-later group already in the sidebar
    assert_select "turbo-stream[action=?][target=?]", "before",
                  ActionView::RecordIdentifier.dom_id(groups.reading_group, :sidebar) do
      assert_select "a[href=?][data-controller=?]", group_path(group), "flash-highlight"
    end
    assert group.member?(users.attendee_two)
  end

  test "joining a group that sorts last appends it to the sidebar" do
    sign_in users.attendee_two
    group = groups.yoga_group # "Yoga Circle" sorts after the member's "Reading Group"

    post group_group_membership_path(group),
         params: { context: "index" },
         as: :turbo_stream

    assert_response :success
    assert_select "turbo-stream[action=?][target=?]", "append", "sidebar_groups" do
      assert_select "a[href=?]", group_path(group)
    end
  end

  test "already a member cannot join again" do
    sign_in users.attendee
    group = groups.book_club

    assert_no_difference "GroupMembership.count" do
      post group_group_membership_path(group)
    end
    assert_redirected_to root_path
  end

  test "member can leave a group" do
    sign_in users.admin
    group = groups.book_club

    assert_difference "GroupMembership.count", -1 do
      delete group_group_membership_path(group)
    end
    assert_redirected_to groups_path
    assert_not group.member?(users.admin)
  end

  test "creator can leave their group" do
    sign_in users.attendee
    group = groups.book_club

    assert_difference "GroupMembership.count", -1 do
      delete group_group_membership_path(group)
    end
    assert_redirected_to groups_path
    assert_not group.member?(users.attendee)
  end

  test "unauthenticated user cannot join" do
    group = groups.book_club
    assert_no_difference "GroupMembership.count" do
      post group_group_membership_path(group)
    end
    assert_redirected_to new_user_session_path
  end
end
