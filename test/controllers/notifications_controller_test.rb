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

  test "show lists unread private conversations" do
    sign_in users(:admin)
    convo = conversations(:admin_attendee_convo)
    convo.direct_messages.create!(sender: users(:attendee), body: "Unread message")

    get notifications_path
    assert_response :success
    assert_match "Private Messages", response.body
  end

  test "show lists unread group chats" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)
    cohort.chat_messages.create!(user: users(:admin), body: "New group message")

    get notifications_path
    assert_response :success
    assert_match "Group Chats", response.body
  end

  test "show displays all caught up when no unreads" do
    sign_in users(:admin)
    # Mark conversations as read
    ConversationParticipant.where(user: users(:admin)).update_all(last_read_at: Time.current)
    # Mark cohort chats as read
    CohortMembership.where(user: users(:admin)).update_all(last_read_at: Time.current)

    get notifications_path
    assert_response :success
    assert_match "All caught up", response.body
  end
end
