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

  test "mark_as_read_by creates or updates feed_post_read" do
    post = feed_posts(:public_post)
    reader = users(:attendee)

    assert_difference "FeedPostRead.count", 1 do
      post.mark_as_read_by(reader)
    end

    assert FeedPostRead.find_by(feed_post: post, user: reader).last_read_at.present?
  end

  test "mark_as_read_by updates existing read record" do
    post = feed_posts(:public_post)
    reader = users(:attendee)
    FeedPostRead.create!(feed_post: post, user: reader, last_read_at: 1.hour.ago)

    assert_no_difference "FeedPostRead.count" do
      post.mark_as_read_by(reader)
    end

    assert FeedPostRead.find_by(feed_post: post, user: reader).last_read_at > 1.minute.ago
  end

  test "mark_as_read_by clears unread mention notifications" do
    post = feed_posts(:public_post)
    reader = users(:attendee)

    Notification.create!(
      user: reader, actor: users(:admin),
      event_type: "mention", title: "Mention", body: "test",
      path: "/feed/#{post.id}",
      notifiable_type: "FeedPost", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "mention", notifiable_type: "FeedPost", notifiable_id: post.id).count
  end

  test "mark_as_read_by clears new_comment notifications" do
    post = feed_posts(:public_post)
    reader = users(:attendee)

    Notification.create!(
      user: reader, actor: users(:admin),
      event_type: "new_comment", title: "Comment", body: "test",
      path: "/feed/#{post.id}",
      notifiable_type: "FeedPost", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "new_comment", notifiable_type: "FeedPost", notifiable_id: post.id).count
  end

  test "valid with photos attached" do
    post = FeedPost.new(user: users(:attendee), body: "Photo post")
    post.photos.attach(io: StringIO.new("fake image data"), filename: "test.jpg", content_type: "image/jpeg")
    assert post.valid?
  end

  test "rejects non-image photo content types" do
    post = FeedPost.new(user: users(:attendee), body: "Bad photo")
    post.photos.attach(io: StringIO.new("not an image"), filename: "test.txt", content_type: "text/plain")
    assert_not post.valid?
    assert_includes post.errors[:photos], "must be JPEG, PNG, GIF, or WebP"
  end

  test "rejects photos over 10MB" do
    post = FeedPost.new(user: users(:attendee), body: "Big photo")
    large_data = "x" * (11 * 1024 * 1024)
    post.photos.attach(io: StringIO.new(large_data), filename: "huge.jpg", content_type: "image/jpeg")
    assert_not post.valid?
    assert_includes post.errors[:photos], "must each be less than 10MB"
  end

  test "rejects more than 10 photos" do
    post = FeedPost.new(user: users(:attendee), body: "Many photos")
    11.times do |i|
      post.photos.attach(io: StringIO.new("fake"), filename: "photo_#{i}.jpg", content_type: "image/jpeg")
    end
    assert_not post.valid?
    assert_includes post.errors[:photos], "cannot exceed 10 images"
  end

  test "mark_as_read_by clears mention notifications on comments" do
    post = feed_posts(:public_post)
    reader = users(:attendee)
    comment = post.feed_post_comments.first

    Notification.create!(
      user: reader, actor: users(:admin),
      event_type: "mention", title: "Mention", body: "test",
      path: "/feed/#{post.id}",
      notifiable_type: "FeedPostComment", notifiable_id: comment.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "mention", notifiable_type: "FeedPostComment", notifiable_id: comment.id).count
  end
end
