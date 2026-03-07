require "test_helper"

class CommentNotifiableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "notifies post author when someone else comments" do
    post = posts(:attendee_post)
    commenter = users(:admin)

    assert_enqueued_with(job: CreateNotificationJob) do
      PostComment.create!(body: "Nice post!", post: post, user: commenter)
    end
  end

  test "does not notify the comment author" do
    post = posts(:attendee_post)
    # attendee is the post author, commenting on own post with no other commenters
    post.post_comments.destroy_all

    assert_no_enqueued_jobs only: CreateNotificationJob do
      PostComment.create!(body: "Updating my own post", post: post, user: users(:attendee))
    end
  end

  test "notifies other commenters on a post" do
    post = feed_posts(:public_post)
    # admin already has a comment on this post
    commenter = users(:attendee_two)

    perform_enqueued_jobs(only: CreateNotificationJob) do
      FeedPostComment.create!(body: "New comment here", feed_post: post, user: commenter)
    end

    # Post author (admin) should have been notified
    notif = Notification.find_by(user: users(:admin), event_type: "new_comment", notifiable_type: "FeedPost", notifiable_id: post.id)
    assert notif.present?
  end

  test "excludes mentioned users from comment notifications" do
    post = feed_posts(:public_post)
    post.feed_post_comments.destroy_all
    author = users(:admin)
    commenter = users(:attendee)

    # First, attendee comments to become a commenter
    FeedPostComment.create!(body: "First comment", feed_post: post, user: commenter)

    # Now admin comments mentioning attendee - attendee should get mention but not comment notification
    perform_enqueued_jobs(only: CreateNotificationJob) do
      FeedPostComment.create!(
        body: "Hey @[#{commenter.name}](#{commenter.id}) great point",
        feed_post: post,
        user: author
      )
    end

    # Attendee should have a mention notification but not a new_comment one
    comment_notifs = Notification.where(user: commenter, event_type: "new_comment", notifiable_type: "FeedPost", notifiable_id: post.id)
    assert_equal 0, comment_notifs.count
  end

  test "notifies via group post comments" do
    group_post = group_posts(:book_club_post)
    commenter = users(:attendee)

    perform_enqueued_jobs(only: CreateNotificationJob) do
      GroupPostComment.create!(body: "Great book!", group_post: group_post, user: commenter)
    end

    # Post author (admin) should be notified
    notif = Notification.find_by(user: users(:admin), event_type: "new_comment", notifiable_type: "GroupPost", notifiable_id: group_post.id)
    assert notif.present?
  end
end
