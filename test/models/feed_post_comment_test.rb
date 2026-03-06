require "test_helper"

class FeedPostCommentTest < ActiveSupport::TestCase
  test "requires body" do
    comment = FeedPostComment.new(feed_post: feed_posts(:public_post), user: users(:attendee))
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "rejects body over 2000 characters" do
    comment = FeedPostComment.new(body: "x" * 2001, feed_post: feed_posts(:public_post), user: users(:attendee))
    assert_not comment.valid?
  end

  test "valid with all attributes" do
    comment = FeedPostComment.new(body: "Nice post!", feed_post: feed_posts(:public_post), user: users(:attendee))
    assert comment.valid?
  end

  test "valid with parent comment on same post" do
    parent = feed_post_comments(:admin_feed_comment)
    reply = FeedPostComment.new(body: "Reply!", feed_post: parent.feed_post, user: users(:attendee), parent: parent)
    assert reply.valid?
  end

  test "invalid with parent comment on different post" do
    parent = feed_post_comments(:attendee_feed_comment) # belongs to pinned_feed_post
    reply = FeedPostComment.new(
      body: "Cross-post reply",
      feed_post: feed_posts(:public_post),
      user: users(:attendee),
      parent: parent
    )
    assert_not reply.valid?
    assert_includes reply.errors[:parent_id], "must belong to the same post"
  end

  test "top_level scope excludes replies" do
    top_level = feed_posts(:public_post).feed_post_comments.top_level
    assert_includes top_level, feed_post_comments(:admin_feed_comment)
    assert_not_includes top_level, feed_post_comments(:reply_to_admin_feed_comment)
  end

  test "replies association returns child comments" do
    parent = feed_post_comments(:admin_feed_comment)
    assert_includes parent.replies, feed_post_comments(:reply_to_admin_feed_comment)
  end

  test "destroying parent destroys nested replies" do
    parent = feed_post_comments(:admin_feed_comment)
    reply_count = 1 + feed_post_comments(:reply_to_admin_feed_comment).replies.count # parent + its nested replies
    assert_difference "FeedPostComment.count", -(1 + reply_count) do
      parent.destroy
    end
  end
end
