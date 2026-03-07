require "test_helper"

class SendPushNotificationJobTest < ActiveJob::TestCase
  setup do
    @admin = users(:admin)
    @original_vapid = Rails.application.config.vapid
    Rails.application.config.vapid = {
      subject: "mailto:test@example.com",
      public_key: "BAAkyPW0XdUESyzxzQNyWKEFVFW4qNPz5G_uBZkoVMLLc9hh8OlYvWqALR8cMzD7eW7I8qq0cNm-ulS1Gdx6h0Y=",
      private_key: "D--LOiHTH9GPoByv1Id7CZ3mvcRahU4yMkMrlgGwhKY="
    }
    # Save original method
    @original_payload_send = WebPush.method(:payload_send)
  end

  teardown do
    Rails.application.config.vapid = @original_vapid
    # Restore original method
    WebPush.define_singleton_method(:payload_send, @original_payload_send)
  end

  test "sends push to all user subscriptions" do
    calls = []
    WebPush.define_singleton_method(:payload_send) { |**kwargs| calls << kwargs }

    SendPushNotificationJob.perform_now(@admin.id, "Test", "Hello", "/test")

    assert_equal @admin.push_subscriptions.count, calls.size
  end

  test "removes expired subscriptions" do
    sub = push_subscriptions(:admin_sub)

    fake_response = Struct.new(:body, :code).new("expired", "410")
    WebPush.define_singleton_method(:payload_send) { |**_| raise WebPush::ExpiredSubscription.new(fake_response, "host") }

    SendPushNotificationJob.perform_now(@admin.id, "Test", "Hello", "/test")

    assert_nil PushSubscription.find_by(id: sub.id)
  end

  test "removes invalid subscriptions" do
    sub = push_subscriptions(:admin_sub)

    fake_response = Struct.new(:body, :code).new("invalid", "404")
    WebPush.define_singleton_method(:payload_send) { |**_| raise WebPush::InvalidSubscription.new(fake_response, "host") }

    SendPushNotificationJob.perform_now(@admin.id, "Test", "Hello", "/test")

    assert_nil PushSubscription.find_by(id: sub.id)
  end

  test "skips when user not found" do
    assert_nothing_raised do
      SendPushNotificationJob.perform_now(-1, "Test", "Hello", "/test")
    end
  end

  test "skips when vapid keys are blank" do
    Rails.application.config.vapid = { subject: "mailto:test@example.com", public_key: nil, private_key: nil }

    assert_nothing_raised do
      SendPushNotificationJob.perform_now(@admin.id, "Test", "Hello", "/test")
    end
  end

  test "direct message enqueues notification job which triggers push" do
    conversation = conversations(:admin_attendee_convo)

    assert_enqueued_with(job: CreateNotificationJob) do
      DirectMessage.create!(
        conversation: conversation,
        sender: @admin,
        body: "Push test message"
      )
    end
  end
end
