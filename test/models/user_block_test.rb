require "test_helper"

class UserBlockTest < ActiveSupport::TestCase
  test "valid block" do
    block = UserBlock.new(blocker: users.admin, blocked: users.attendee_two)
    assert block.valid?
  end

  test "cannot block yourself" do
    block = UserBlock.new(blocker: users.attendee, blocked: users.attendee)
    assert_not block.valid?
    assert_includes block.errors[:blocked], "cannot block yourself"
  end

  test "cannot block an admin" do
    block = UserBlock.new(blocker: users.attendee, blocked: users.admin)
    assert_not block.valid?
    assert_includes block.errors[:blocked], "cannot be blocked"
  end

  test "cannot block the same user twice" do
    block = UserBlock.new(blocker: users.attendee, blocked: users.attendee_two)
    assert_not block.valid?
    assert_includes block.errors[:blocked_id], "has already been taken"
  end

  test "User#blocks? returns true when blocking" do
    assert users.attendee.blocks?(users.attendee_two)
    assert_not users.attendee.blocks?(users.admin)
  end

  test "User#blocked_user_ids returns ids of blocked users" do
    ids = users.attendee.blocked_user_ids
    assert_includes ids, users.attendee_two.id
    assert_not_includes ids, users.admin.id
  end

  test "blocked users are accessible through the association" do
    blocker = users.attendee
    blocked = users.attendee_two
    assert_includes blocker.blocked_users, blocked
  end

  test "Blockable.visible_to excludes content authored by blocked users" do
    blocker = users.admin
    blocked = users.attendee
    blocker.user_blocks.create!(blocked: blocked)

    visible = FeedPost.visible_to(blocker)
    assert_not visible.exists?(user_id: blocked.id), "blocked author's posts should be hidden"
    assert visible.exists?(user_id: blocker.id), "other authors' posts should remain visible"
  end

  test "Blockable.visible_to is mutual: the blocked user cannot see the blocker's content" do
    blocker = users.attendee # attendee blocks attendee_two via fixture
    blocked = users.attendee_two

    visible = FeedPost.visible_to(blocked)
    assert_not visible.exists?(user_id: blocker.id), "blocker's posts should be hidden from the blocked user"
  end

  test "hidden_content_user_ids covers both block directions" do
    assert_includes users.attendee.hidden_content_user_ids, users.attendee_two.id
    assert_includes users.attendee_two.hidden_content_user_ids, users.attendee.id
  end
end
