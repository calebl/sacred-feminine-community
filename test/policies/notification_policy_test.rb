require "test_helper"

class NotificationPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @notification = notifications(:admin_new_member)
  end

  test "notification recipient can update their notification" do
    assert NotificationPolicy.new(@admin, @notification).update?
  end

  test "another user cannot update someone else's notification" do
    assert_not NotificationPolicy.new(@attendee, @notification).update?
  end

  test "scope returns only notifications belonging to the user" do
    scope = NotificationPolicy::Scope.new(@admin, Notification).resolve
    assert scope.all? { |n| n.user_id == @admin.id }
    assert_includes scope, @notification
  end

  test "scope returns empty for a user with no notifications" do
    scope = NotificationPolicy::Scope.new(users(:attendee_two), Notification).resolve
    assert_empty scope
  end
end
