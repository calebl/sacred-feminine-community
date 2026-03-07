require "test_helper"

class Notifications::MarkAllReadsControllerTest < ActionDispatch::IntegrationTest
  test "create requires authentication" do
    post notifications_mark_all_read_path
    assert_redirected_to new_user_session_path
  end

  test "create marks all unread notifications as read" do
    user = users(:admin)
    sign_in user
    Notification.where(user: user).update_all(read_at: nil)
    assert user.notifications.unread.count > 0

    post notifications_mark_all_read_path
    assert_redirected_to notifications_path
    assert_equal 0, user.notifications.unread.count
  end

  test "create does not affect other users notifications" do
    admin = users(:admin)
    attendee = users(:attendee)
    sign_in admin

    Notification.where(user: admin).update_all(read_at: nil)
    attendee.notifications.create!(
      actor: admin, event_type: "new_member",
      title: "Test", body: "Test notification", path: "/admin/dashboard"
    )

    post notifications_mark_all_read_path
    assert_equal 1, attendee.notifications.unread.count
  end
end
