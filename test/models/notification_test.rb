require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "requires title" do
    notification = Notification.new(user: users(:admin))
    assert_not notification.valid?
    assert_includes notification.errors[:title], "can't be blank"
  end

  test "requires user" do
    notification = Notification.new(title: "Test")
    assert_not notification.valid?
    assert_includes notification.errors[:user], "must exist"
  end

  test "actor is optional" do
    notification = Notification.new(user: users(:admin), title: "System Notification")
    assert notification.valid?
  end

  test "read? returns false when read_at is nil" do
    assert_not notifications(:admin_new_member).read?
  end

  test "read? returns true when read_at is present" do
    assert notifications(:admin_read_notification).read?
  end

  test "unread scope returns only unread notifications" do
    unread = Notification.unread.where(user: users(:admin))
    assert_includes unread, notifications(:admin_new_member)
    assert_not_includes unread, notifications(:admin_read_notification)
  end

  test "recent scope returns up to 30 notifications ordered by newest first" do
    recent = Notification.where(user: users(:admin)).recent
    assert_equal notifications(:admin_new_member), recent.first
  end
end
