require "test_helper"

class Notifications::SeenControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:attendee)
    @post = posts(:pinned_announcement)
  end

  test "create marks the post's notifications read and re-broadcasts" do
    sign_in @user
    notification = Notification.create!(user: @user, event_type: "new_post",
                                        title: "x", notifiable: @post)

    assert_enqueued_with(job: BroadcastUnreadBadgeJob) do
      post notifications_seen_path, params: { type: "post", id: @post.id }
    end

    assert_response :ok
    assert_not_nil notification.reload.read_at
  end

  test "create handles comments" do
    sign_in @user
    comment = post_comments(:admin_comment)
    notification = Notification.create!(user: @user, event_type: "new_comment",
                                        title: "x", notifiable: comment.post)

    post notifications_seen_path, params: { type: "post_comment", id: comment.id }

    assert_response :ok
    assert_not_nil notification.reload.read_at
  end

  test "create returns not_found for unknown record" do
    sign_in @user
    post notifications_seen_path, params: { type: "post", id: 0 }
    assert_response :not_found
  end

  test "create returns not_found for unknown type" do
    sign_in @user
    post notifications_seen_path, params: { type: "bogus", id: @post.id }
    assert_response :not_found
  end

  test "create requires authentication" do
    post notifications_seen_path, params: { type: "post", id: @post.id }
    assert_redirected_to new_user_session_path
  end

  test "create returns not_found (no oracle) and does not mark for an unviewable post" do
    outsider = users(:attendee_two) # not a member of @post's cohort
    sign_in outsider
    notification = Notification.create!(user: outsider, event_type: "new_post",
                                        title: "x", notifiable: @post)

    post notifications_seen_path, params: { type: "post", id: @post.id }

    # Same response as a missing record, so existence can't be probed.
    assert_response :not_found
    assert_nil notification.reload.read_at
  end
end
