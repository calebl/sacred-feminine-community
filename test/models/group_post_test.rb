require "test_helper"

class GroupPostTest < ActiveSupport::TestCase
  test "requires body" do
    post = GroupPost.new(group: groups(:book_club), user: users(:attendee))
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "valid with body" do
    post = GroupPost.new(group: groups(:book_club), user: users(:attendee), body: "Hello")
    assert post.valid?
  end

  test "pinned_first scope orders pinned posts first" do
    posts_list = groups(:book_club).group_posts.pinned_first.to_a
    pinned_indices = posts_list.each_index.select { |i| posts_list[i].pinned? }
    unpinned_indices = posts_list.each_index.reject { |i| posts_list[i].pinned? }

    if pinned_indices.any? && unpinned_indices.any?
      assert pinned_indices.max < unpinned_indices.min
    end
  end

  test "destroying group_post destroys comments" do
    post = group_posts(:book_club_post)
    assert post.group_post_comments.any?
    assert_difference "GroupPostComment.count", -post.group_post_comments.count do
      post.destroy
    end
  end

  test "unread_comment_count returns all non-author comments when no read record" do
    post = group_posts(:book_club_post)
    reader = users(:attendee)
    expected = post.group_post_comments.where.not(user: reader).count
    assert_operator expected, :>, 0
    assert_equal expected, post.unread_comment_count(reader)
  end

  test "unread_comment_count returns zero after reading" do
    post = group_posts(:book_club_post)
    reader = users(:attendee)
    GroupPostRead.create!(group_post: post, user: reader, last_read_at: Time.current)
    assert_equal 0, post.unread_comment_count(reader)
  end

  test "unread_comment_count returns only comments after last_read_at" do
    post = group_posts(:book_club_post)
    reader = users(:attendee)
    read_at = 45.minutes.ago
    GroupPostRead.create!(group_post: post, user: reader, last_read_at: read_at)

    expected = post.group_post_comments.where.not(user: reader)
                   .where("group_post_comments.created_at > ?", read_at).count
    assert_equal expected, post.unread_comment_count(reader)
  end

  test "mark_as_read_by clears unread mention notifications" do
    post = group_posts(:book_club_post)
    reader = users(:attendee)

    Notification.create!(
      user: reader, actor: users(:admin),
      event_type: "mention", title: "Mention", body: "test",
      path: "/groups/1/group_posts/#{post.id}",
      notifiable_type: "GroupPost", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "mention", notifiable_type: "GroupPost", notifiable_id: post.id).count
  end

  test "mark_as_read_by clears new_comment notifications" do
    post = group_posts(:book_club_post)
    reader = users(:attendee)

    Notification.create!(
      user: reader, actor: users(:admin),
      event_type: "new_comment", title: "Comment", body: "test",
      path: "/groups/1/group_posts/#{post.id}",
      notifiable_type: "GroupPost", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "new_comment", notifiable_type: "GroupPost", notifiable_id: post.id).count
  end
end
