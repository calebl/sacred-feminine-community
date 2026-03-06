require "test_helper"

class FeedPostCommentPolicyTest < ActiveSupport::TestCase
  test "any authenticated user can create comment" do
    comment = FeedPostComment.new(feed_post: feed_posts(:public_post))
    assert FeedPostCommentPolicy.new(users(:attendee), comment).create?
    assert FeedPostCommentPolicy.new(users(:attendee_two), comment).create?
  end

  test "author can destroy own comment" do
    assert FeedPostCommentPolicy.new(users(:attendee), feed_post_comments(:attendee_feed_comment)).destroy?
  end

  test "admin can destroy any comment" do
    assert FeedPostCommentPolicy.new(users(:admin), feed_post_comments(:attendee_feed_comment)).destroy?
  end

  test "non-author cannot destroy comment" do
    assert_not FeedPostCommentPolicy.new(users(:attendee_two), feed_post_comments(:attendee_feed_comment)).destroy?
  end
end
