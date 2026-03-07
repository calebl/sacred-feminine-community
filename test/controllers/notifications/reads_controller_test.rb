require "test_helper"

class Notifications::ReadsControllerTest < ActionDispatch::IntegrationTest
  test "create marks notification as read and redirects to path" do
    sign_in users(:admin)
    notification = notifications(:admin_new_member)
    assert_nil notification.read_at

    post notifications_reads_path(notification_id: notification.id)

    assert_redirected_to "/admin/dashboard"
    assert_not_nil notification.reload.read_at
  end

  test "create does not overwrite existing read_at" do
    sign_in users(:admin)
    notification = notifications(:admin_read_notification)
    original_read_at = notification.read_at

    post notifications_reads_path(notification_id: notification.id)

    assert_equal original_read_at.to_i, notification.reload.read_at.to_i
  end

  test "create requires authentication" do
    post notifications_reads_path(notification_id: notifications(:admin_new_member).id)
    assert_redirected_to new_user_session_path
  end

  test "create prevents reading another user's notification" do
    sign_in users(:attendee)
    post notifications_reads_path(notification_id: notifications(:admin_new_member).id)
    assert_response :not_found
    assert_nil notifications(:admin_new_member).reload.read_at
  end

  test "create redirects to notifications path when path is nil" do
    sign_in users(:admin)
    notification = notifications(:admin_new_member)
    notification.update_column(:path, nil)

    post notifications_reads_path(notification_id: notification.id)

    assert_redirected_to notifications_path
  end
end
