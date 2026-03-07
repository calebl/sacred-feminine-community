require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  test "valid with all attributes" do
    sub = PushSubscription.new(
      user: users(:admin),
      endpoint: "https://push.example.com/unique-endpoint",
      p256dh_key: "test_p256dh_key",
      auth_key: "test_auth_key"
    )
    assert sub.valid?
  end

  test "requires endpoint" do
    sub = PushSubscription.new(user: users(:admin), p256dh_key: "key", auth_key: "auth")
    assert_not sub.valid?
    assert_includes sub.errors[:endpoint], "can't be blank"
  end

  test "requires p256dh_key" do
    sub = PushSubscription.new(user: users(:admin), endpoint: "https://push.example.com/x", auth_key: "auth")
    assert_not sub.valid?
    assert_includes sub.errors[:p256dh_key], "can't be blank"
  end

  test "requires auth_key" do
    sub = PushSubscription.new(user: users(:admin), endpoint: "https://push.example.com/x", p256dh_key: "key")
    assert_not sub.valid?
    assert_includes sub.errors[:auth_key], "can't be blank"
  end

  test "endpoint must be unique" do
    existing = push_subscriptions(:admin_sub)
    sub = PushSubscription.new(
      user: users(:attendee),
      endpoint: existing.endpoint,
      p256dh_key: "key",
      auth_key: "auth"
    )
    assert_not sub.valid?
    assert_includes sub.errors[:endpoint], "has already been taken"
  end

  test "belongs to user" do
    sub = push_subscriptions(:admin_sub)
    assert_equal users(:admin), sub.user
  end

  test "user has_many push_subscriptions with dependent destroy" do
    assert_equal :destroy, User.reflect_on_association(:push_subscriptions).options[:dependent]
  end
end
