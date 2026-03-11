require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires body" do
    post = Post.new(cohort: cohorts(:kabul_retreat), user: users(:attendee))
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "valid with body" do
    post = Post.new(cohort: cohorts(:kabul_retreat), user: users(:attendee), body: "Hello world")
    assert post.valid?
  end

  test "pinned_first scope orders pinned posts first" do
    posts_list = cohorts(:kabul_retreat).posts.pinned_first.to_a
    pinned_indices = posts_list.each_index.select { |i| posts_list[i].pinned? }
    unpinned_indices = posts_list.each_index.reject { |i| posts_list[i].pinned? }

    if pinned_indices.any? && unpinned_indices.any?
      assert pinned_indices.max < unpinned_indices.min
    end
  end

  test "destroying post destroys comments" do
    post = posts(:attendee_post)
    assert post.post_comments.any?
    assert_difference "PostComment.count", -post.post_comments.count do
      post.destroy
    end
  end

  test "unread_comment_count returns all non-author comments when no read record" do
    post = posts(:attendee_post)
    reader = users(:admin)
    expected = post.post_comments.where.not(user: reader).count
    assert_operator expected, :>, 0
    assert_equal expected, post.unread_comment_count(reader)
  end

  test "unread_comment_count returns zero after reading" do
    post = posts(:attendee_post)
    reader = users(:admin)
    PostRead.create!(post: post, user: reader, last_read_at: Time.current)
    assert_equal 0, post.unread_comment_count(reader)
  end

  test "unread_comment_count returns only comments after last_read_at" do
    post = posts(:attendee_post)
    reader = users(:admin)
    read_at = 45.minutes.ago
    PostRead.create!(post: post, user: reader, last_read_at: read_at)

    expected = post.post_comments.where.not(user: reader)
                   .where("post_comments.created_at > ?", read_at).count
    assert_equal expected, post.unread_comment_count(reader)
  end

  test "mark_as_read_by clears unread mention notifications" do
    post = posts(:attendee_post)
    reader = users(:admin)

    Notification.create!(
      user: reader, actor: users(:attendee),
      event_type: "mention", title: "Mention", body: "test",
      path: "/cohorts/1/posts/#{post.id}",
      notifiable_type: "Post", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "mention", notifiable_type: "Post", notifiable_id: post.id).count
  end

  test "mark_as_read_by clears new_comment notifications" do
    post = posts(:attendee_post)
    reader = users(:admin)

    Notification.create!(
      user: reader, actor: users(:attendee),
      event_type: "new_comment", title: "Comment", body: "test",
      path: "/cohorts/1/posts/#{post.id}",
      notifiable_type: "Post", notifiable_id: post.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "new_comment", notifiable_type: "Post", notifiable_id: post.id).count
  end

  test "mark_as_read_by clears mention notifications on post comments" do
    post = posts(:attendee_post)
    reader = users(:admin)
    comment = post.post_comments.first

    Notification.create!(
      user: reader, actor: users(:attendee),
      event_type: "mention", title: "Mention", body: "test",
      path: "/cohorts/1/posts/#{post.id}",
      notifiable_type: "PostComment", notifiable_id: comment.id
    )

    post.mark_as_read_by(reader)
    assert_equal 0, Notification.unread.where(user: reader, event_type: "mention", notifiable_type: "PostComment", notifiable_id: comment.id).count
  end
end
