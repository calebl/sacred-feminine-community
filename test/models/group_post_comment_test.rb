require "test_helper"

class GroupPostCommentTest < ActiveSupport::TestCase
  test "valid with parent comment on same post" do
    parent = group_post_comments.admin_group_comment
    reply = GroupPostComment.new(body: "Reply!", group_post: parent.group_post, user: users.attendee, parent: parent)

    assert reply.valid?
  end

  test "invalid with parent comment on different post" do
    reply = GroupPostComment.new(
      body: "Cross-post reply",
      group_post: group_posts.yoga_post,
      user: users.attendee,
      parent: group_post_comments.admin_group_comment
    )

    assert_not reply.valid?
    assert_includes reply.errors[:parent_id], "must belong to the same post"
  end
end
