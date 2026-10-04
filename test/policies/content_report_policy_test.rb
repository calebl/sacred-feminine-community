require "test_helper"

class ContentReportPolicyTest < ActiveSupport::TestCase
  def allowed?(user, reportable)
    ContentReportPolicy.new(user, ContentReport.new(reporter: user, reportable: reportable)).create?
  end

  test "members can report other members' profiles" do
    assert allowed?(users.attendee, users.attendee_two)
  end

  test "members can report a profile they blocked" do
    reporter = users.attendee
    profile = users.attendee_two
    assert reporter.blocks?(profile)
    assert allowed?(reporter, profile)
  end

  test "nobody can report themselves" do
    assert_not allowed?(users.attendee, users.attendee)
  end

  test "removed members can't be reported" do
    users.attendee_two.discard!
    assert_not allowed?(users.attendee, users.attendee_two)
  end

  test "cohort comments are reportable only by cohort members" do
    comment = post_comments.admin_comment

    assert allowed?(users.attendee, comment)
    assert_not allowed?(users.attendee_two, comment)
  end

  test "posts and comments in discarded containers cannot be reported" do
    cohort = cohorts.kabul_retreat
    group = groups.book_club
    cohort.discard!
    group.discard!

    assert_not allowed?(users.attendee, posts.pinned_announcement)
    assert_not allowed?(users.attendee, post_comments.admin_comment)
    assert_not allowed?(users.attendee, group_posts.book_club_post)
    assert_not allowed?(users.attendee, group_post_comments.admin_group_comment)
  end

  test "comments on hidden-author posts cannot be reported" do
    reporter = users.attendee
    hidden_author = users.male_member
    comments = [
      PostComment.create!(post: posts.male_member_post, user: users.admin, body: "Visible cohort comment"),
      GroupPostComment.create!(group_post: group_posts.male_member_group_post, user: users.admin, body: "Visible group comment"),
      FeedPostComment.create!(feed_post: feed_posts.male_member_feed_post, user: users.admin, body: "Visible feed comment")
    ]
    reporter.user_blocks.create!(blocked: hidden_author)

    comments.each { |comment| assert_not allowed?(reporter, comment) }
  end

  test "hidden comments and their visible-author replies cannot be reported" do
    reporter = users.attendee
    hidden_author = users.attendee_two
    visible_author = users.admin
    hidden_comments = [
      PostComment.create!(post: posts.attendee_post, user: hidden_author, body: "Hidden cohort comment"),
      GroupPostComment.create!(group_post: group_posts.book_club_pinned, user: hidden_author, body: "Hidden group comment"),
      FeedPostComment.create!(feed_post: feed_posts.public_post, user: hidden_author, body: "Hidden feed comment")
    ]
    replies = [
      PostComment.create!(post: posts.attendee_post, user: visible_author, parent: hidden_comments[0], body: "Nested cohort reply"),
      GroupPostComment.create!(group_post: group_posts.book_club_pinned, user: visible_author, parent: hidden_comments[1], body: "Nested group reply"),
      FeedPostComment.create!(feed_post: feed_posts.public_post, user: visible_author, parent: hidden_comments[2], body: "Nested feed reply")
    ]
    assert reporter.blocks?(hidden_author)
    (hidden_comments + replies).each { |comment| assert_not allowed?(reporter, comment) }
  end
end
