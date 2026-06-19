require "test_helper"

class FeedPostTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "requires body" do
    post = FeedPost.new(user: users.attendee)
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "valid with body" do
    post = FeedPost.new(user: users.attendee, body: "Hello world")
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
    post = feed_posts.public_post
    assert post.feed_post_comments.any?
    assert_difference "FeedPostComment.count", -post.feed_post_comments.count do
      post.destroy
    end
  end

  test "unread_comment_count returns all non-author comments when no read record exists" do
    post = feed_posts.public_post
    reader = users.attendee

    expected = post.feed_post_comments.where.not(user: reader).count
    assert_operator expected, :>, 0
    assert_equal expected, post.unread_comment_count(reader)
  end

  test "unread_comment_count returns zero for own comments" do
    post = feed_posts.public_post
    author = users.admin

    # Admin authored the post and all non-reply comments; create a read record in the future
    FeedPostRead.create!(feed_post: post, user: author, last_read_at: Time.current)

    assert_equal 0, post.unread_comment_count(author)
  end

  test "unread_comment_count returns only comments after last_read_at" do
    post = feed_posts.public_post
    reader = users.attendee

    # Mark as read at a time between existing comments
    read_at = 25.minutes.ago
    FeedPostRead.create!(feed_post: post, user: reader, last_read_at: read_at)

    expected = post.feed_post_comments.where.not(user: reader)
                   .where("feed_post_comments.created_at > ?", read_at).count
    assert_equal expected, post.unread_comment_count(reader)
  end

  test "mark_as_read_by creates or updates feed_post_read" do
    post = feed_posts.public_post
    reader = users.attendee

    assert_difference "FeedPostRead.count", 1 do
      post.mark_as_read_by(reader)
    end

    assert FeedPostRead.find_by(feed_post: post, user: reader).last_read_at.present?
  end

  test "mark_as_read_by updates existing read record" do
    post = feed_posts.public_post
    reader = users.attendee
    FeedPostRead.create!(feed_post: post, user: reader, last_read_at: 1.hour.ago)

    assert_no_difference "FeedPostRead.count" do
      post.mark_as_read_by(reader)
    end

    assert FeedPostRead.find_by(feed_post: post, user: reader).last_read_at > 1.minute.ago
  end

  test "mark_as_read_by clears unread mention notifications" do
    post = feed_posts.public_post
    reader = users.attendee

    Notification.create!(
      user: reader, actor: users.admin,
      event_type: "mention", title: "Mention", body: "test",
      path: "/feed/#{post.id}",
      notifiable_type: "FeedPost", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "mention", notifiable_type: "FeedPost", notifiable_id: post.id).count
  end

  test "mark_as_read_by clears new_comment notifications" do
    post = feed_posts.public_post
    reader = users.attendee

    Notification.create!(
      user: reader, actor: users.admin,
      event_type: "new_comment", title: "Comment", body: "test",
      path: "/feed/#{post.id}",
      notifiable_type: "FeedPost", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "new_comment", notifiable_type: "FeedPost", notifiable_id: post.id).count
  end

  test "mark_as_read_by clears mention notifications on comments" do
    post = feed_posts.public_post
    reader = users.attendee
    comment = post.feed_post_comments.first

    Notification.create!(
      user: reader, actor: users.admin,
      event_type: "mention", title: "Mention", body: "test",
      path: "/feed/#{post.id}",
      notifiable_type: "FeedPostComment", notifiable_id: comment.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "mention", notifiable_type: "FeedPostComment", notifiable_id: comment.id).count
  end

  test "admin feed post enqueues new_post notifications for all other users" do
    author = users.admin

    FeedPost.create!(user: author, body: "Community announcement")

    recipient_ids = new_post_recipient_ids
    assert_includes recipient_ids, users.attendee.id
    assert_includes recipient_ids, users.attendee_two.id
    assert_includes recipient_ids, users.admin_two.id
    assert_not_includes recipient_ids, author.id
  end

  test "member feed post does not enqueue new_post notifications" do
    FeedPost.create!(user: users.attendee, body: "Just a member post")

    assert_empty new_post_recipient_ids
  end

  test "admin feed post does not double-notify mentioned users" do
    mentioned = users.attendee

    FeedPost.create!(user: users.admin, body: "Hey @[#{mentioned.name}](#{mentioned.id})")

    assert_not_includes new_post_recipient_ids, mentioned.id
  end

  test "new_post notification body is generic and path points to the feed post" do
    post = FeedPost.create!(user: users.admin, body: "SECRET CONTENT that should never leak")

    jobs = enqueued_new_post_jobs
    assert jobs.any?
    jobs.each do |j|
      args = j["arguments"].last
      assert_no_match(/SECRET CONTENT/, args["body"])
      assert_equal "Posted in the community feed", args["body"]
      assert_equal "/feed/#{post.id}", args["path"]
    end
  end

  test "mark_as_read_by clears new_post notifications" do
    post = feed_posts.public_post
    reader = users.attendee

    Notification.create!(
      user: reader, actor: users.admin,
      event_type: "new_post", title: "Post", body: "test",
      path: "/feed/#{post.id}",
      notifiable_type: "FeedPost", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "new_post", notifiable_type: "FeedPost", notifiable_id: post.id).count
  end

  private

  def enqueued_new_post_jobs
    enqueued_jobs.select do |j|
      j["job_class"] == "CreateNotificationJob" &&
        j["arguments"].last["event_type"] == "new_post"
    end
  end

  def new_post_recipient_ids
    enqueued_new_post_jobs.map { |j| j["arguments"].last["user_id"] }
  end
end
