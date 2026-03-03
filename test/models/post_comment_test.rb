require "test_helper"

class PostCommentTest < ActiveSupport::TestCase
  test "requires body" do
    comment = PostComment.new(post: posts(:attendee_post), user: users(:attendee))
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "rejects body over 2000 characters" do
    comment = PostComment.new(body: "x" * 2001, post: posts(:attendee_post), user: users(:attendee))
    assert_not comment.valid?
  end

  test "valid with all attributes" do
    comment = PostComment.new(body: "Nice post!", post: posts(:attendee_post), user: users(:attendee))
    assert comment.valid?
  end

  test "valid with parent comment" do
    parent = post_comments(:admin_comment)
    reply = PostComment.new(body: "Reply!", post: parent.post, user: users(:attendee), parent: parent)
    assert reply.valid?
  end

  test "top_level scope excludes replies" do
    top_level = posts(:attendee_post).post_comments.top_level
    assert_includes top_level, post_comments(:admin_comment)
    assert_not_includes top_level, post_comments(:reply_to_admin_comment)
  end

  test "replies association returns child comments" do
    parent = post_comments(:admin_comment)
    assert_includes parent.replies, post_comments(:reply_to_admin_comment)
  end

  test "destroying parent destroys nested replies" do
    parent = post_comments(:admin_comment)
    reply = post_comments(:reply_to_admin_comment)
    nested = post_comments(:nested_reply)
    assert_difference "PostComment.count", -3 do
      parent.destroy
    end
  end

  test "deeply nested reply is valid" do
    nested = post_comments(:nested_reply)
    assert nested.valid?
    assert_equal post_comments(:reply_to_admin_comment), nested.parent
  end
end
