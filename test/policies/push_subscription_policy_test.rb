require "test_helper"

class PushSubscriptionPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users.admin
    @attendee = users.attendee
    @subscription = push_subscriptions.admin_sub
  end

  test "any user can create a push subscription" do
    assert PushSubscriptionPolicy.new(@attendee, PushSubscription.new).create?
  end

  test "subscription owner can destroy it" do
    assert PushSubscriptionPolicy.new(@admin, @subscription).destroy?
  end

  test "non-owner cannot destroy another user's subscription" do
    assert_not PushSubscriptionPolicy.new(@attendee, @subscription).destroy?
  end
end
