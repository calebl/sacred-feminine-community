require "test_helper"

# `visible_to` (SQL) and `reject_hidden_from` (in memory) are the two halves of
# one rule, and every content surface uses one or the other. These cover the
# in-memory half and the model APIs built on it, for each of the three post and
# comment types.
class BlockableTest < ActiveSupport::TestCase
  setup do
    @viewer = users.women_only_member
    @hidden_author = users.male_member
  end

  test "reject_hidden_from drops records authored by a hidden user" do
    kept = PostComment.reject_hidden_from(posts.pinned_announcement.post_comments, @viewer)

    assert_not_includes kept, post_comments.male_member_comment
    assert_includes kept, post_comments.announcement_comment
  end

  test "reject_hidden_from keeps everything when nothing is hidden" do
    kept = PostComment.reject_hidden_from(posts.pinned_announcement.post_comments, users.admin)

    assert_equal posts.pinned_announcement.post_comments.count, kept.size
  end

  test "reject_hidden_from ignores an unsaved record built onto the association" do
    post = posts.pinned_announcement
    post.post_comments.load
    post.post_comments.build

    kept = PostComment.reject_hidden_from(post.post_comments, users.admin)

    assert kept.all?(&:persisted?)
    assert_equal post.post_comments.count, kept.size
  end

  test "visible_comments hides a hidden author's comments and replies alike" do
    visible = posts.pinned_announcement.visible_comments(@viewer)

    assert_not_includes visible, post_comments.male_member_comment
    assert_not_includes visible, post_comments.male_member_announcement_reply
    assert_includes visible, post_comments.attendee_announcement_reply
  end

  test "visible_replies hides a hidden author's reply on every comment type" do
    {
      post_comments.announcement_comment => post_comments.male_member_announcement_reply,
      group_post_comments.group_thread_parent => group_post_comments.male_member_group_reply,
      feed_post_comments.feed_thread_parent => feed_post_comments.male_member_feed_reply
    }.each do |parent, hidden_reply|
      assert_includes parent.replies, hidden_reply, "seed check for #{parent.class}"
      assert_not_includes parent.visible_replies(@viewer), hidden_reply,
                          "#{parent.class} should hide the excluded member's reply"
      assert_includes parent.visible_replies(users.admin), hidden_reply,
                      "#{parent.class} should still show it to an admin"
    end
  end

  test "visible_replies returns replies oldest first" do
    parent = post_comments.announcement_comment
    replies = parent.visible_replies(users.admin)

    assert_equal replies.sort_by(&:created_at), replies
  end

  test "visible_replies reuses a preloaded association instead of requerying" do
    parent = PostComment.includes(replies: :user).find(post_comments.announcement_comment.id)
    viewer = users.admin
    viewer.hidden_content_user_ids # memoized per request in real use

    assert_no_queries do
      parent.visible_replies(viewer).each { |reply| reply.user.name }
    end
  end
end
