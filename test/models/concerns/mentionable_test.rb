require "test_helper"

class MentionableTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @cohort = cohorts(:kabul_retreat)
  end

  test "extracts mentions from post body" do
    post_record = @cohort.posts.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id}) check this out",
      user: @attendee
    )

    assert_equal 1, post_record.mentions.count
    mention = post_record.mentions.first
    assert_equal @admin, mention.user
    assert_equal @attendee, mention.mentioner
  end

  test "does not create mention for the author" do
    post_record = @cohort.posts.create!(
      body: "Talking to myself @[#{@attendee.name}](#{@attendee.id})",
      user: @attendee
    )

    assert_equal 0, post_record.mentions.count
  end

  test "extracts multiple mentions" do
    post_record = @cohort.posts.create!(
      body: "@[#{@admin.name}](#{@admin.id}) and @[#{@attendee_two.name}](#{@attendee_two.id})",
      user: @attendee
    )

    assert_equal 2, post_record.mentions.count
  end

  test "deduplicates repeated mentions of same user" do
    post_record = @cohort.posts.create!(
      body: "@[#{@admin.name}](#{@admin.id}) hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )

    assert_equal 1, post_record.mentions.count
  end

  test "ignores invalid user IDs" do
    post_record = @cohort.posts.create!(
      body: "@[Nobody](999999)",
      user: @attendee
    )

    assert_equal 0, post_record.mentions.count
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
    post_record = @cohort.posts.create!(
      body: "Just a regular message",
      user: @attendee
    )

    assert_equal 0, post_record.mentions.count
  end

  test "destroying mentionable destroys mentions" do
    post_record = @cohort.posts.create!(
      body: "@[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )

    assert_equal 1, post_record.mentions.count
    post_record.destroy
    assert_equal 0, Mention.where(mentionable: post_record).count
  end

  test "respects mention_nobody privacy in cohort post" do
    @admin.update_column(:mention_privacy, 0)
    post_record = @cohort.posts.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 0, post_record.mentions.count
  end

  test "respects mention_groups_and_cohorts privacy in cohort post" do
    @admin.update_column(:mention_privacy, 1)
    post_record = @cohort.posts.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 1, post_record.mentions.count
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

  test "respects mention_groups_and_cohorts privacy in group post" do
    @admin.update_column(:mention_privacy, 1)
    group = groups(:book_club)
    group_post = group.group_posts.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 1, group_post.mentions.count
  end

  test "mention_nobody blocks group post mentions" do
    @admin.update_column(:mention_privacy, 0)
    group = groups(:book_club)
    group_post = group.group_posts.create!(
      body: "Hey @[#{@admin.name}](#{@admin.id})",
      user: @attendee
    )
    assert_equal 0, group_post.mentions.count
  end

  test "mention_context returns correct context for each model" do
    assert_equal :cohort, Post.new.send(:mention_context)
    assert_equal :cohort, PostComment.new.send(:mention_context)
    assert_equal :group, GroupPost.new.send(:mention_context)
    assert_equal :group, GroupPostComment.new.send(:mention_context)
    assert_equal :feed, FeedPost.new.send(:mention_context)
    assert_equal :feed, FeedPostComment.new.send(:mention_context)
    assert_equal :dm, DirectMessage.new.send(:mention_context)
  end

  test "ignores discarded users" do
    pending = users(:pending_invite)

    post_record = @cohort.posts.create!(
      body: "@[#{pending.name}](#{pending.id})",
      user: @attendee
    )

    assert_equal 0, post_record.mentions.count
  end
end
