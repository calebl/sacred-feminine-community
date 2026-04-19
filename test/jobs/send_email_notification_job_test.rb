require "test_helper"

class SendEmailNotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @user = users(:attendee)
    @actor = users(:admin)
    @notification = Notification.create!(
      user: @user,
      actor: @actor,
      event_type: "mention",
      title: "Test",
      body: "You were mentioned",
      path: "/feed"
    )
  end

  test "sends an email when the user's preference for the event type is enabled" do
    assert_emails 1 do
      SendEmailNotificationJob.perform_now(@notification.id)
    end
  end

  test "does not send when the user disabled that event type" do
    @user.update!(email_on_mention: false)

    assert_no_emails do
      SendEmailNotificationJob.perform_now(@notification.id)
    end
  end

  test "other event-type preferences do not affect this event" do
    @user.update!(email_on_direct_message: false)

    assert_emails 1 do
      SendEmailNotificationJob.perform_now(@notification.id)
    end
  end

  test "skips when the notification no longer exists" do
    @notification.destroy!

    assert_no_emails do
      SendEmailNotificationJob.perform_now(@notification.id)
    end
  end

  test "sends to the user's email address" do
    SendEmailNotificationJob.perform_now(@notification.id)

    assert_equal [ @user.email ], ActionMailer::Base.deliveries.last.to
  end

  test "does not send new_post email when the user disabled new_post" do
    @user.update!(email_on_new_post: false)
    new_post_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "new_post", title: @actor.name,
      body: "Posted in Test Cohort", path: "/cohorts/1/posts/1"
    )

    assert_no_emails do
      SendEmailNotificationJob.perform_now(new_post_notification.id)
    end
  end

  test "does not send any email when the master toggle is off" do
    @user.update!(email_notifications_enabled: false)

    assert_no_emails do
      SendEmailNotificationJob.perform_now(@notification.id)
    end
  end

  test "always sends email for help_request_reply when master toggle is on" do
    reply_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "help_request_reply", title: "Reply",
      body: "Someone replied", path: "/help_requests/1"
    )

    assert_emails 1 do
      SendEmailNotificationJob.perform_now(reply_notification.id)
    end
  end

  test "does not send email for new_member event (never configurable)" do
    new_member_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "new_member", title: "New Member",
      body: "Someone joined", path: "/admin/dashboard"
    )

    assert_no_emails do
      SendEmailNotificationJob.perform_now(new_member_notification.id)
    end
  end

  test "does not send email for help_request event (never configurable)" do
    help_request_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "help_request", title: "New Help Request",
      body: "Someone needs help", path: "/help_requests/1"
    )

    assert_no_emails do
      SendEmailNotificationJob.perform_now(help_request_notification.id)
    end
  end

  test "sends email for direct_message when the preference is enabled" do
    dm_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "direct_message", title: @actor.name,
      body: "Sent you a private message", path: "/conversations/1"
    )

    assert_emails 1 do
      SendEmailNotificationJob.perform_now(dm_notification.id)
    end
  end

  test "does not send direct_message email when the preference is disabled" do
    @user.update!(email_on_direct_message: false)
    dm_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "direct_message", title: @actor.name,
      body: "Sent you a private message", path: "/conversations/1"
    )

    assert_no_emails do
      SendEmailNotificationJob.perform_now(dm_notification.id)
    end
  end

  test "sends email for new_comment when the preference is enabled" do
    comment_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "new_comment", title: @actor.name,
      body: "Commented on your post", path: "/cohorts/1/posts/1"
    )

    assert_emails 1 do
      SendEmailNotificationJob.perform_now(comment_notification.id)
    end
  end

  test "does not send new_comment email when the preference is disabled" do
    @user.update!(email_on_new_comment: false)
    comment_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "new_comment", title: @actor.name,
      body: "Commented on your post", path: "/cohorts/1/posts/1"
    )

    assert_no_emails do
      SendEmailNotificationJob.perform_now(comment_notification.id)
    end
  end

  test "help_request_reply email is suppressed by master toggle" do
    @user.update!(email_notifications_enabled: false)
    reply_notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "help_request_reply", title: "Reply",
      body: "Someone replied", path: "/help_requests/1"
    )

    assert_no_emails do
      SendEmailNotificationJob.perform_now(reply_notification.id)
    end
  end
end
