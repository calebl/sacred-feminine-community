require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "show displays notification center" do
    sign_in users(:attendee)
    get notifications_path
    assert_response :success
  end

  test "show displays all caught up when no notifications" do
    user = users(:admin)
    sign_in user
    Notification.where(user: user).delete_all

    get notifications_path
    assert_response :success
    assert_match "All caught up", response.body
  end

  test "show lists recent notifications including read ones" do
    sign_in users(:admin)
    get notifications_path
    assert_response :success
    assert_match "Jane Attendee has joined the community", response.body
    assert_match "Sarah Member has joined the community", response.body
  end

  test "show displays unread dot for unread notifications" do
    user = users(:admin)
    sign_in user
    Notification.where(user: user).update_all(read_at: nil)

    get notifications_path
    assert_response :success
    assert_select "span.bg-sf-red.rounded-full"
  end

  test "show does not display unread dot for read notifications" do
    user = users(:admin)
    sign_in user
    Notification.where(user: user).update_all(read_at: Time.current)

    get notifications_path
    assert_response :success
    assert_select "span.bg-sf-red.rounded-full", count: 0
  end

  test "show displays mark all as read button when unread notifications exist" do
    user = users(:admin)
    sign_in user
    Notification.where(user: user).update_all(read_at: nil)

    get notifications_path
    assert_response :success
    assert_match "Mark all as read", response.body
  end

  test "show hides mark all as read button when all read" do
    user = users(:admin)
    sign_in user
    Notification.where(user: user).update_all(read_at: Time.current)

    get notifications_path
    assert_response :success
    assert_no_match "Mark all as read", response.body
  end
end
