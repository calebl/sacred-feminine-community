require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  # Index
  test "any user sees all groups on index" do
    sign_in users(:attendee)
    get groups_path
    assert_response :success
    assert_match "Book Club", response.body
    assert_match "Yoga Circle", response.body
  end

  test "index shows New Group button for all users" do
    sign_in users(:attendee)
    get groups_path
    assert_select "a[href=?]", new_group_path
  end

  # Show - public visibility
  test "non-member can view group page" do
    sign_in users(:attendee_two)
    get group_path(groups(:book_club))
    assert_response :success
  end

  test "non-member sees join button" do
    sign_in users(:attendee_two)
    get group_path(groups(:book_club))
    assert_match "Join Group", response.body
  end

  test "non-member does not see feed or chat" do
    sign_in users(:attendee_two)
    get group_path(groups(:book_club))
    assert_no_match "Group Chat", response.body
  end

  test "member can view group with tabs" do
    sign_in users(:attendee)
    get group_path(groups(:book_club))
    assert_response :success
    assert_match "Feed", response.body
    assert_no_match "Group Chat", response.body
    assert_match "Members", response.body
  end

  # Create
  test "creator is auto-added as member" do
    sign_in users(:attendee)
    assert_difference "Group.count" do
      post groups_path, params: {
        group: { name: "New Group", description: "A new group" }
      }
    end
    group = Group.last
    assert_redirected_to group_path(group)
    assert group.member?(users(:attendee)), "Creator should be auto-added as member"
  end

  test "admin creator is also auto-added as member" do
    sign_in users(:admin)
    assert_difference "Group.count" do
      post groups_path, params: {
        group: { name: "Admin Group", description: "Created by admin" }
      }
    end
    group = Group.last
    assert_redirected_to group_path(group)
    assert group.member?(users(:admin)), "Admin creator should also be auto-added as member"
  end

  test "create with invalid params re-renders form" do
    sign_in users(:attendee)
    assert_no_difference "Group.count" do
      post groups_path, params: { group: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  # Update
  test "creator can update group" do
    sign_in users(:attendee)
    patch group_path(groups(:book_club)), params: {
      group: { name: "Updated Book Club" }
    }
    assert_redirected_to group_path(groups(:book_club))
    assert_equal "Updated Book Club", groups(:book_club).reload.name
  end

  test "admin can update any group" do
    sign_in users(:admin)
    patch group_path(groups(:book_club)), params: {
      group: { name: "Admin Updated" }
    }
    assert_redirected_to group_path(groups(:book_club))
    assert_equal "Admin Updated", groups(:book_club).reload.name
  end

  test "non-creator non-admin cannot update group" do
    sign_in users(:attendee_two)
    patch group_path(groups(:book_club)), params: {
      group: { name: "Hacked" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked", groups(:book_club).reload.name
  end

  # Destroy
  test "creator can archive group" do
    sign_in users(:attendee)
    group = groups(:book_club)
    assert_no_difference "Group.count" do
      delete group_path(group)
    end
    assert_redirected_to groups_path
    assert group.reload.discarded?
  end

  test "admin can archive any group" do
    sign_in users(:admin)
    group = groups(:book_club)
    delete group_path(group)
    assert_redirected_to groups_path
    assert group.reload.discarded?
  end

  test "non-creator non-admin cannot archive group" do
    sign_in users(:attendee_two)
    group = groups(:book_club)
    delete group_path(group)
    assert_redirected_to root_path
    assert_not group.reload.discarded?
  end

  test "archived group is not accessible" do
    sign_in users(:admin)
    group = groups(:book_club)
    group.discard
    get group_path(group)
    assert_response :not_found
  end

  # Mark as read
  test "show marks group chat as read for member" do
    sign_in users(:attendee)
    group = groups(:book_club)
    membership = group.group_memberships.find_by(user: users(:attendee))
    assert_nil membership.last_read_at

    get group_path(group)

    membership.reload
    assert_not_nil membership.last_read_at
  end

  test "show displays New Post button" do
    sign_in users(:attendee)
    get group_path(groups(:book_club), tab: :feed)
    assert_response :success
    assert_match "New Post", response.body
  end

  # Edit
  test "creator can access edit form" do
    sign_in users(:attendee)
    get edit_group_path(groups(:book_club))
    assert_response :success
  end

  # Leave button
  test "member sees leave button" do
    sign_in users(:admin)
    get group_path(groups(:book_club))
    assert_match "Leave", response.body
  end

  test "creator sees leave button" do
    sign_in users(:attendee)
    get group_path(groups(:book_club))
    assert_match "Leave", response.body
  end

  # Creator loses permissions after leaving
  test "creator who left cannot update group" do
    sign_in users(:attendee)
    group = groups(:book_club)
    group.group_memberships.find_by(user: users(:attendee)).destroy

    patch group_path(group), params: { group: { name: "Hacked" } }
    assert_redirected_to root_path
    assert_not_equal "Hacked", group.reload.name
  end

  test "creator who left cannot destroy group" do
    sign_in users(:attendee)
    group = groups(:book_club)
    group.group_memberships.find_by(user: users(:attendee)).destroy

    delete group_path(group)
    assert_redirected_to root_path
    assert_not group.reload.discarded?
  end
end
