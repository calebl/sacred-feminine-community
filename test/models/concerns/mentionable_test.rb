require "test_helper"

class MentionableTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @cohort = cohorts(:kabul_retreat)
  end

  test "extracts mentions from chat message body" do
    message = @cohort.chat_messages.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id}) check this out",
      user: @attendee
    )

    assert_equal 1, message.mentions.count
    mention = message.mentions.first
    assert_equal @admin, mention.user
    assert_equal @attendee, mention.mentioner
  end

  test "does not create mention for the author" do
    message = @cohort.chat_messages.create!(
      body: "Talking to myself @[#{@attendee.name}](#{@attendee.id})",
      user: @attendee
    )

    assert_equal 0, message.mentions.count
  end

  test "extracts multiple mentions" do
    message = @cohort.chat_messages.create!(
      body: "@[#{@admin.name}](#{@admin.id}) and @[#{@attendee_two.name}](#{@attendee_two.id})",
      user: @attendee
    )

    assert_equal 2, message.mentions.count
  end

  test "deduplicates repeated mentions of same user" do
    message = @cohort.chat_messages.create!(
      body: "@[#{@admin.name}](#{@admin.id}) hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )

    assert_equal 1, message.mentions.count
  end

  test "ignores invalid user IDs" do
    message = @cohort.chat_messages.create!(
      body: "@[Nobody](999999)",
      user: @attendee
    )

    assert_equal 0, message.mentions.count
  end

  test "works with DirectMessage sender" do
    conversation = conversations(:admin_attendee_convo)

    message = DirectMessage.create!(
      body: "Hey @[#{@attendee.name}](#{@attendee.id})",
      conversation: conversation,
      sender: @admin
    )

    assert_equal 1, message.mentions.count
    assert_equal @attendee, message.mentions.first.user
    assert_equal @admin, message.mentions.first.mentioner
  end

  test "works with PostComment" do
    post_record = posts(:attendee_post)

    comment = PostComment.create!(
      body: "Great point @[#{@admin.name}](#{@admin.id})",
      post: post_record,
      user: @attendee
    )

    assert_equal 1, comment.mentions.count
  end

  test "works with GroupChatMessage" do
    group = groups(:book_club)

    message = group.group_chat_messages.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )

    assert_equal 1, message.mentions.count
  end

  test "works with GroupPostComment" do
    group = groups(:book_club)
    group_post = group.group_posts.create!(body: "Test post", user: @admin)

    comment = GroupPostComment.create!(
      body: "@[#{@attendee.name}](#{@attendee.id}) thoughts?",
      group_post: group_post,
      user: @admin
    )

    assert_equal 1, comment.mentions.count
  end

  test "no mentions when body has no mention syntax" do
    message = @cohort.chat_messages.create!(
      body: "Just a regular message",
      user: @attendee
    )

    assert_equal 0, message.mentions.count
  end

  test "destroying mentionable destroys mentions" do
    message = @cohort.chat_messages.create!(
      body: "@[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )

    assert_equal 1, message.mentions.count
    message.destroy
    assert_equal 0, Mention.where(mentionable: message).count
  end

  test "respects mention_nobody privacy in cohort chat" do
    @admin.update_column(:mention_privacy, 0)
    message = @cohort.chat_messages.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 0, message.mentions.count
  end

  test "respects mention_groups_and_cohorts privacy in cohort chat" do
    @admin.update_column(:mention_privacy, 1)
    message = @cohort.chat_messages.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 1, message.mentions.count
  end

  test "respects mention_groups_and_cohorts privacy blocks feed comment mentions" do
    @admin.update_column(:mention_privacy, 1)
    feed_post = feed_posts(:public_post)
    comment = FeedPostComment.create!(
      body: "@[#{@admin.name}](#{@admin.id}) check this",
      feed_post: feed_post,
      user: @attendee
    )
    assert_equal 0, comment.mentions.count
  end

  test "mention_everywhere allows feed comment mentions" do
    @admin.update_column(:mention_privacy, 2)
    feed_post = feed_posts(:public_post)
    comment = FeedPostComment.create!(
      body: "@[#{@admin.name}](#{@admin.id}) check this",
      feed_post: feed_post,
      user: @attendee
    )
    assert_equal 1, comment.mentions.count
  end

  test "respects mention_groups_and_cohorts privacy in group chat" do
    @admin.update_column(:mention_privacy, 1)
    group = groups(:book_club)
    message = group.group_chat_messages.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 1, message.mentions.count
  end

  test "mention_nobody blocks group chat mentions" do
    @admin.update_column(:mention_privacy, 0)
    group = groups(:book_club)
    message = group.group_chat_messages.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 0, message.mentions.count
  end

  test "mention_context returns correct context for each model" do
    assert_equal :cohort, @cohort.chat_messages.build.mention_context
    assert_equal :cohort, Post.new.mention_context
    assert_equal :cohort, PostComment.new.mention_context
    assert_equal :group, GroupChatMessage.new.mention_context
    assert_equal :group, GroupPost.new.mention_context
    assert_equal :group, GroupPostComment.new.mention_context
    assert_equal :feed, FeedPostComment.new.mention_context
    assert_equal :dm, DirectMessage.new.mention_context
  end

  test "ignores discarded users" do
    pending = users(:pending_invite)

    message = @cohort.chat_messages.create!(
      body: "@[#{pending.name}](#{pending.id})",
      user: @attendee
    )

    assert_equal 0, message.mentions.count
  end
end
