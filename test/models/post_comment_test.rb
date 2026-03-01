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
end
