require "test_helper"

class PostCommentPolicyTest < ActiveSupport::TestCase
  test "member can create comment" do
    comment = PostComment.new(post: posts(:attendee_post))
    assert PostCommentPolicy.new(users(:attendee), comment).create?
  end

  test "admin can create comment even when not a member" do
    comment = PostComment.new(post: posts(:attendee_post))
    assert PostCommentPolicy.new(users(:admin), comment).create?
  end

  test "non-member cannot create comment" do
    comment = PostComment.new(post: posts(:attendee_post))
    assert_not PostCommentPolicy.new(users(:attendee_two), comment).create?
  end

  test "author can destroy own comment" do
    assert PostCommentPolicy.new(users(:attendee), post_comments(:attendee_comment)).destroy?
  end

  test "admin can destroy any comment" do
    assert PostCommentPolicy.new(users(:admin), post_comments(:attendee_comment)).destroy?
  end

  test "non-author cannot destroy comment" do
    assert_not PostCommentPolicy.new(users(:attendee_two), post_comments(:attendee_comment)).destroy?
  end
end
