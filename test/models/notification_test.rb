require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "requires title" do
    notification = Notification.new(user: users(:admin), event_type: "new_member")
    assert_not notification.valid?
    assert_includes notification.errors[:title], "can't be blank"
  end

  test "requires user" do
    notification = Notification.new(title: "Test", event_type: "new_member")
    assert_not notification.valid?
    assert_includes notification.errors[:user], "must exist"
  end

  test "requires event_type" do
    notification = Notification.new(user: users(:admin), title: "Test")
    assert_not notification.valid?
    assert_includes notification.errors[:event_type], "can't be blank"
  end

  test "rejects invalid event_type" do
    notification = Notification.new(user: users(:admin), title: "Test", event_type: "invalid")
    assert_not notification.valid?
    assert_includes notification.errors[:event_type], "is not included in the list"
  end

  test "accepts valid event_types" do
    %w[mention direct_message new_comment new_member help_request help_request_reply].each do |type|
      notification = Notification.new(user: users(:admin), title: "Test", event_type: type)
      assert notification.valid?, "Expected #{type} to be valid"
    end
  end

  test "actor is optional" do
    notification = Notification.new(user: users(:admin), title: "System Notification", event_type: "new_member")
    assert notification.valid?
  end

  test "notifiable is optional" do
    notification = Notification.new(user: users(:admin), title: "Test", event_type: "new_member")
    assert notification.valid?
  end

  test "notifiable polymorphic association works" do
    post = posts(:pinned_announcement)
    notification = Notification.create!(
      user: users(:admin), actor: users(:attendee),
      title: "Test", event_type: "new_comment",
      notifiable: post
    )
    assert_equal post, notification.notifiable
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
    assert_equal 2, recent.size
    assert recent.first.created_at >= recent.last.created_at
  end
end
