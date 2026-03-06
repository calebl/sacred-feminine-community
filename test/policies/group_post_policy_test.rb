require "test_helper"

class GroupPostPolicyTest < ActiveSupport::TestCase
  test "member can show post in their group" do
    assert GroupPostPolicy.new(users(:attendee), group_posts(:book_club_pinned)).show?
  end

  test "non-member cannot show post" do
    assert_not GroupPostPolicy.new(users(:attendee_two), group_posts(:book_club_post)).show?
  end

  test "member can create post" do
    post = GroupPost.new(group: groups(:book_club))
    assert GroupPostPolicy.new(users(:attendee), post).create?
  end

  test "non-member cannot create post" do
    post = GroupPost.new(group: groups(:book_club))
    assert_not GroupPostPolicy.new(users(:attendee_two), post).create?
  end

  test "author can update own post" do
    assert GroupPostPolicy.new(users(:attendee), group_posts(:book_club_pinned)).update?
  end

  test "admin cannot update another user's post" do
    assert_not GroupPostPolicy.new(users(:admin), group_posts(:book_club_pinned)).update?
  end

  test "non-author member cannot update post" do
    assert_not GroupPostPolicy.new(users(:attendee), group_posts(:book_club_post)).update?
  end

  test "author can destroy own post" do
    assert GroupPostPolicy.new(users(:attendee), group_posts(:book_club_pinned)).destroy?
  end

  test "admin can destroy any post" do
    assert GroupPostPolicy.new(users(:admin), group_posts(:book_club_pinned)).destroy?
  end

  test "non-author member cannot destroy post" do
    assert_not GroupPostPolicy.new(users(:attendee), group_posts(:book_club_post)).destroy?
  end
end
