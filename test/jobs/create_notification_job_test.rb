require "test_helper"

class CreateNotificationJobTest < ActiveJob::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
  end

  test "creates a notification for the user" do
    assert_difference "Notification.count", 1 do
      CreateNotificationJob.perform_now(
        user_id: @admin.id,
        actor_id: @attendee.id,
        event_type: "new_member",
        title: "New Member",
        body: "Test joined",
        path: "/admin/dashboard"
      )
    end

    notification = Notification.last
    assert_equal @admin, notification.user
    assert_equal @attendee, notification.actor
    assert_equal "new_member", notification.event_type
    assert_equal "New Member", notification.title
    assert_nil notification.read_at
  end

  test "enqueues SendPushNotificationJob and BroadcastUnreadBadgeJob" do
    assert_enqueued_with(job: SendPushNotificationJob) do
      assert_enqueued_with(job: BroadcastUnreadBadgeJob) do
        CreateNotificationJob.perform_now(
          user_id: @admin.id,
          actor_id: @attendee.id,
          event_type: "mention",
          title: "Mention",
          body: "You were mentioned",
          path: "/test"
        )
      end
    end
  end

  test "does nothing if user not found" do
    assert_no_difference "Notification.count" do
      CreateNotificationJob.perform_now(
        user_id: 0,
        actor_id: @attendee.id,
        event_type: "new_member",
        title: "Test",
        body: "Test",
        path: "/test"
      )
    end
  end

  test "sets notifiable when provided" do
    post = posts(:pinned_announcement)

    CreateNotificationJob.perform_now(
      user_id: @admin.id,
      actor_id: @attendee.id,
      event_type: "new_comment",
      title: "New Comment",
      body: "Someone commented",
      path: "/test",
      notifiable_type: "Post",
      notifiable_id: post.id
    )

    notification = Notification.last
    assert_equal post, notification.notifiable
  end

  test "deduplicates by group_key when existing unread notification exists" do
    CreateNotificationJob.perform_now(
      user_id: @admin.id,
      actor_id: @attendee.id,
      event_type: "direct_message",
      title: @attendee.name,
      body: "Sent you a private message",
      path: "/conversations/1",
      group_key: "conversation:1"
    )

    assert_no_difference "Notification.count" do
      CreateNotificationJob.perform_now(
        user_id: @admin.id,
        actor_id: @attendee.id,
        event_type: "direct_message",
        title: @attendee.name,
        body: "2 new messages",
        path: "/conversations/1",
        group_key: "conversation:1"
      )
    end

    notification = Notification.where(user: @admin, group_key: "conversation:1").last
    assert_equal "2 new messages", notification.body
  end

  test "upsert_grouped updates title and actor on existing unread" do
    CreateNotificationJob.perform_now(
      user_id: @admin.id,
      actor_id: @attendee.id,
      event_type: "new_comment",
      title: "First commenter",
      body: "Commented on your post",
      path: "/feed/1",
      notifiable_type: "FeedPost",
      notifiable_id: 1,
      group_key: "feed_post_comments:1"
    )

    second_commenter = users(:attendee_two)
    CreateNotificationJob.perform_now(
      user_id: @admin.id,
      actor_id: second_commenter.id,
      event_type: "new_comment",
      title: "Second commenter",
      body: "2 people commented",
      path: "/feed/1",
      notifiable_type: "FeedPost",
      notifiable_id: 1,
      group_key: "feed_post_comments:1"
    )

    notification = Notification.where(user: @admin, group_key: "feed_post_comments:1").last
    assert_equal "Second commenter", notification.title
    assert_equal second_commenter.id, notification.actor_id
    assert_equal "2 people commented", notification.body
  end

  test "creates notification without group_key" do
    assert_difference "Notification.count", 1 do
      CreateNotificationJob.perform_now(
        user_id: @admin.id,
        actor_id: @attendee.id,
        event_type: "mention",
        title: "Mention",
        body: "You were mentioned",
        path: "/test",
        notifiable_type: "Post",
        notifiable_id: posts(:attendee_post).id
      )
    end
  end

  test "creates new notification for group_key when previous is read" do
    CreateNotificationJob.perform_now(
      user_id: @admin.id,
      actor_id: @attendee.id,
      event_type: "direct_message",
      title: @attendee.name,
      body: "Message 1",
      path: "/conversations/1",
      group_key: "conversation:1"
    )

    Notification.where(user: @admin, group_key: "conversation:1").update_all(read_at: Time.current)

    assert_difference "Notification.count", 1 do
      CreateNotificationJob.perform_now(
        user_id: @admin.id,
        actor_id: @attendee.id,
        event_type: "direct_message",
        title: @attendee.name,
        body: "Message 2",
        path: "/conversations/1",
        group_key: "conversation:1"
      )
    end
  end
end
