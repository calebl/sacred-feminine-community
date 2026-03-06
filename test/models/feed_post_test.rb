require "test_helper"

class FeedPostTest < ActiveSupport::TestCase
  test "requires body" do
    post = FeedPost.new(user: users(:attendee))
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "valid with body" do
    post = FeedPost.new(user: users(:attendee), body: "Hello world")
    assert post.valid?
  end

  test "pinned_first scope orders pinned posts first" do
    posts_list = FeedPost.pinned_first.to_a
    pinned_indices = posts_list.each_index.select { |i| posts_list[i].pinned? }
    unpinned_indices = posts_list.each_index.reject { |i| posts_list[i].pinned? }

    if pinned_indices.any? && unpinned_indices.any?
      assert pinned_indices.max < unpinned_indices.min
    end
  end

  test "destroying post destroys comments" do
    post = feed_posts(:public_post)
    assert post.feed_post_comments.any?
    assert_difference "FeedPostComment.count", -post.feed_post_comments.count do
      post.destroy
    end
  end

  test "unread_comment_count returns all non-author comments when no read record exists" do
    post = feed_posts(:public_post)
    reader = users(:attendee)

    expected = post.feed_post_comments.where.not(user: reader).count
    assert_operator expected, :>, 0
    assert_equal expected, post.unread_comment_count(reader)
  end

  test "unread_comment_count returns zero for own comments" do
    post = feed_posts(:public_post)
    author = users(:admin)

    # Admin authored the post and all non-reply comments; create a read record in the future
    FeedPostRead.create!(feed_post: post, user: author, last_read_at: Time.current)

    assert_equal 0, post.unread_comment_count(author)
  end

  test "unread_comment_count returns only comments after last_read_at" do
    post = feed_posts(:public_post)
    reader = users(:attendee)

    # Mark as read at a time between existing comments
    read_at = 25.minutes.ago
    FeedPostRead.create!(feed_post: post, user: reader, last_read_at: read_at)

    expected = post.feed_post_comments.where.not(user: reader)
                   .where("feed_post_comments.created_at > ?", read_at).count
    assert_equal expected, post.unread_comment_count(reader)
  end
end
