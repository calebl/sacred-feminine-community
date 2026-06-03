require "test_helper"

class GroupPostCommentPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @comment = group_post_comments(:admin_group_comment)
  end

  test "group member can create a comment" do
    assert GroupPostCommentPolicy.new(@attendee, @comment).create?
  end

  test "non-member cannot create a comment" do
    assert_not GroupPostCommentPolicy.new(@attendee_two, @comment).create?
  end

  test "admin can create a comment in a group they have not joined" do
    comment = GroupPostComment.new(group_post: group_posts(:reading_group_post))
    assert GroupPostCommentPolicy.new(@admin, comment).create?
  end

  test "comment author can destroy their own comment" do
    assert GroupPostCommentPolicy.new(@admin, @comment).destroy?
  end

  test "admin can destroy any comment" do
    other_comment = group_post_comments(:attendee_group_comment)
    assert GroupPostCommentPolicy.new(@admin, other_comment).destroy?
  end

  test "other member cannot destroy someone else's comment" do
    assert_not GroupPostCommentPolicy.new(@attendee, @comment).destroy?
  end
end
