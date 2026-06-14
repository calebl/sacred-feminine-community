require "test_helper"

# Covers the scroll-into-view "seen" marking methods on posts and comments.
class UnreadSeenMarkingTest < ActiveSupport::TestCase
  setup do
    @user = users(:attendee)
  end

  def unread(attrs)
    Notification.create!({ user: @user, title: "x" }.merge(attrs))
  end

  test "Post#mark_seen_by clears new_post and mention but not new_comment" do
    post = posts(:pinned_announcement)
    new_post = unread(event_type: "new_post", notifiable: post)
    mention = unread(event_type: "mention", notifiable: post)
    new_comment = unread(event_type: "new_comment", notifiable: post)

    post.mark_seen_by(@user)

    assert_not_nil new_post.reload.read_at
    assert_not_nil mention.reload.read_at
    assert_nil new_comment.reload.read_at
  end

  test "PostComment#mark_seen_by clears comment mention and parent post new_comment, not new_post" do
    comment = post_comments(:admin_comment)
    post = comment.post
    new_post = unread(event_type: "new_post", notifiable: post)
    new_comment = unread(event_type: "new_comment", notifiable: post)
    mention = unread(event_type: "mention", notifiable: comment)

    comment.mark_seen_by(@user)

    assert_not_nil new_comment.reload.read_at
    assert_not_nil mention.reload.read_at
    assert_nil new_post.reload.read_at
  end

  test "GroupPost#mark_seen_by clears new_post and mention but not new_comment" do
    group_post = group_posts(:book_club_post)
    new_post = unread(event_type: "new_post", notifiable: group_post)
    new_comment = unread(event_type: "new_comment", notifiable: group_post)

    group_post.mark_seen_by(@user)

    assert_not_nil new_post.reload.read_at
    assert_nil new_comment.reload.read_at
  end

  test "GroupPostComment#mark_seen_by clears mention and parent new_comment" do
    comment = group_post_comments(:admin_group_comment)
    new_comment = unread(event_type: "new_comment", notifiable: comment.group_post)
    mention = unread(event_type: "mention", notifiable: comment)

    comment.mark_seen_by(@user)

    assert_not_nil new_comment.reload.read_at
    assert_not_nil mention.reload.read_at
  end

  test "marking only affects the given user's notifications" do
    post = posts(:pinned_announcement)
    other = Notification.create!(user: users(:admin), event_type: "new_post",
                                 title: "x", notifiable: post)

    post.mark_seen_by(@user)

    assert_nil other.reload.read_at
  end
end
