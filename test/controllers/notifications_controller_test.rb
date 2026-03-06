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

  test "show does not list group chats section" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)
    cohort.chat_messages.create!(user: users(:admin), body: "New group message")

    get notifications_path
    assert_response :success
    assert_no_match "Group Chats", response.body
  end

  test "show displays all caught up when no unreads" do
    sign_in users(:admin)
    # Mark conversations as read
    ConversationParticipant.where(user: users(:admin)).update_all(last_read_at: Time.current)
    # Mark cohort chats and posts as read
    CohortMembership.where(user: users(:admin)).update_all(last_read_at: Time.current, posts_last_read_at: Time.current)
    # Mark all posts as read for comment notifications
    Post.joins(:post_comments).where(post_comments: { user_id: users(:admin).id }).distinct.each do |post|
      PostRead.find_or_create_by(post: post, user: users(:admin)).update(last_read_at: Time.current)
    end

    get notifications_path
    assert_response :success
    assert_match "All caught up", response.body
  end

  test "show lists unread posts" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)
    cohort.posts.create!(body: "New post content", user: users(:admin))

    get notifications_path
    assert_response :success
    assert_match "New Posts", response.body
  end

  test "show lists unread comments on posts user commented on" do
    sign_in users(:attendee)
    # attendee has commented on pinned_announcement
    post_record = posts(:pinned_announcement)
    post_record.post_comments.create!(user: users(:admin), body: "New reply")

    get notifications_path
    assert_response :success
    assert_match "New Comments", response.body
  end

  test "show lists unread mentions" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)
    cohort.chat_messages.create!(
      body: "@[#{users(:admin).name}](#{users(:admin).id})",
      user: users(:attendee)
    )

    get notifications_path
    assert_response :success
    assert_match "Mentions", response.body
    assert_match "mentioned you", response.body
  end

  test "show does not list read mentions" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)
    cohort.chat_messages.create!(
      body: "@[#{users(:admin).name}](#{users(:admin).id})",
      user: users(:attendee)
    )
    Mention.where(user: users(:admin)).update_all(read_at: Time.current)

    # Mark all other unreads as read
    ConversationParticipant.where(user: users(:admin)).update_all(last_read_at: Time.current)
    CohortMembership.where(user: users(:admin)).update_all(last_read_at: Time.current, posts_last_read_at: Time.current)
    Post.joins(:post_comments).where(post_comments: { user_id: users(:admin).id }).distinct.each do |post|
      PostRead.find_or_create_by(post: post, user: users(:admin)).update(last_read_at: Time.current)
    end

    get notifications_path
    assert_response :success
    assert_no_match "Mentions", response.body
  end
end
