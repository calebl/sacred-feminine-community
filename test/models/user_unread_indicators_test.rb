require "test_helper"

class UserUnreadIndicatorsTest < ActiveSupport::TestCase
  setup do
    @user = users(:attendee)
  end

  def unread(attrs)
    Notification.create!({ user: @user, event_type: "new_post", title: "x" }.merge(attrs))
  end

  test "unread_messages? is true only with an unread DirectMessage notification" do
    assert_not @user.unread_messages?

    unread(event_type: "direct_message", notifiable_type: "DirectMessage", notifiable_id: 1)

    assert User.find(@user.id).unread_messages?
  end

  test "unread_messages? ignores read DM notifications" do
    unread(event_type: "direct_message", notifiable_type: "DirectMessage",
           notifiable_id: 1, read_at: Time.current)

    assert_not @user.unread_messages?
  end

  test "unread_cohort_ids maps posts and comments back to their cohort" do
    post = posts(:pinned_announcement) # kabul_retreat
    comment = post_comments(:admin_comment) # post: attendee_post -> kabul_retreat

    unread(event_type: "new_post", notifiable: post)
    unread(event_type: "mention", notifiable: comment)

    assert_includes @user.unread_cohort_ids, cohorts(:kabul_retreat).id
    assert_not_includes @user.unread_cohort_ids, cohorts(:bali_retreat).id
  end

  test "unread_group_ids maps group posts and comments to their group" do
    unread(event_type: "new_post", notifiable: group_posts(:book_club_post))
    unread(event_type: "mention", notifiable: group_post_comments(:attendee_group_comment))

    ids = @user.unread_group_ids
    assert_includes ids, groups(:book_club).id
    assert_not_includes ids, groups(:reading_group).id
  end

  test "unread_group_ids ignores new_member notifications" do
    unread(event_type: "new_member", notifiable: groups(:yoga_group))

    assert_not_includes @user.unread_group_ids, groups(:yoga_group).id
  end

  test "unread_for_post? only for matching unread post/mention" do
    post = posts(:pinned_announcement)
    unread(event_type: "new_post", notifiable: post)

    assert @user.unread_for_post?(post)
    assert_not User.find(@user.id).unread_for_post?(posts(:bali_post))
  end

  test "unread_for_post_comment? covers comment mentions and the post's grouped new_comment" do
    comment = post_comments(:admin_comment) # authored by admin, not @user
    unread(event_type: "new_comment", notifiable: comment.post)

    assert @user.unread_for_post_comment?(comment)
  end

  test "unread_for_post_comment? ignores the user's own comments" do
    own_comment = post_comments(:attendee_comment) # authored by @user
    unread(event_type: "new_comment", notifiable: own_comment.post)

    assert_not @user.unread_for_post_comment?(own_comment)
  end

  test "unread_for_post_comment? ignores comments already read via PostRead" do
    comment = post_comments(:admin_comment)
    unread(event_type: "new_comment", notifiable: comment.post)
    PostRead.create!(user: @user, post: comment.post, last_read_at: Time.current)

    assert_not User.find(@user.id).unread_for_post_comment?(comment)
  end

  test "unread_for_post_comment? still counts a direct mention even when read" do
    comment = post_comments(:admin_comment)
    unread(event_type: "mention", notifiable: comment)
    PostRead.create!(user: @user, post: comment.post, last_read_at: Time.current)

    assert User.find(@user.id).unread_for_post_comment?(comment)
  end
end
