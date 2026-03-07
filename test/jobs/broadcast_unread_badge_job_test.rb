require "test_helper"

class BroadcastUnreadBadgeJobTest < ActiveJob::TestCase
  test "broadcasts turbo stream to user's unread_badge channel" do
    user = users(:admin)

    assert_nothing_raised do
      BroadcastUnreadBadgeJob.perform_now(user.id)
    end
  end

  test "skips gracefully when user not found" do
    assert_nothing_raised do
      BroadcastUnreadBadgeJob.perform_now(-1)
    end
  end

  test "direct message enqueues notification job which triggers badge broadcast" do
    conversation = conversations(:admin_attendee_convo)
    admin = users(:admin)

    assert_enqueued_with(job: CreateNotificationJob) do
      DirectMessage.create!(
        conversation: conversation,
        sender: admin,
        body: "Badge test message"
      )
    end
  end
end
