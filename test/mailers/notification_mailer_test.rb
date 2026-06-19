require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  setup do
    @user = users.attendee
    @actor = users.admin
    @notification = Notification.create!(
      user: @user,
      actor: @actor,
      event_type: "mention",
      title: "#{@actor.name} mentioned you",
      body: "You were mentioned in a post",
      path: "/cohorts/1"
    )
  end

  test "sends to the user's email with the notification title as subject" do
    email = NotificationMailer.new_notification(@notification)

    assert_equal [ @user.email ], email.to
    assert_equal "#{@actor.name} mentioned you", email.subject
  end

  test "body contains the notification title and body" do
    email = NotificationMailer.new_notification(@notification)

    assert_match "#{@actor.name} mentioned you", email.body.encoded
    assert_match "You were mentioned in a post", email.body.encoded
  end

  test "body includes a link to the notification path" do
    email = NotificationMailer.new_notification(@notification)

    assert_match "/cohorts/1", email.body.encoded
  end

  test "body includes a link to notification settings" do
    email = NotificationMailer.new_notification(@notification)

    assert_match Rails.application.routes.url_helpers.edit_profile_url(@user, host: "example.com"), email.body.encoded
  end

  test "does not include notifiable record body content" do
    # Even if a notification has a notifiable association, the email only uses
    # the generic title/body fields — never content from the linked record.
    dm = DirectMessage.create!(
      conversation: conversations.admin_attendee_convo,
      sender: @actor,
      body: "secret private content that must not leak"
    )
    notification = Notification.create!(
      user: @user, actor: @actor,
      event_type: "direct_message",
      title: @actor.name,
      body: "Sent you a private message",
      path: "/conversations/#{dm.conversation_id}",
      notifiable: dm
    )

    email = NotificationMailer.new_notification(notification)

    assert_no_match dm.body, email.body.encoded
  end
end
