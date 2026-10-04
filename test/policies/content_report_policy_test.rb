require "test_helper"

class ContentReportPolicyTest < ActiveSupport::TestCase
  def allowed?(user, reportable)
    ContentReportPolicy.new(user, ContentReport.new(reporter: user, reportable: reportable)).create?
  end

  test "members can report other members' profiles" do
    assert allowed?(users.attendee, users.attendee_two)
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

  test "hidden comments cannot be reported through any comment type" do
    reporter = users.attendee
    author = users.attendee_two
    comments = [
      PostComment.create!(post: posts.attendee_post, user: author, body: "Hidden cohort comment"),
      GroupPostComment.create!(group_post: group_posts.book_club_pinned, user: author, body: "Hidden group comment"),
      FeedPostComment.create!(feed_post: feed_posts.public_post, user: author, body: "Hidden feed comment")
    ]
    reporter.user_blocks.create!(blocked: author)

    comments.each { |comment| assert_not allowed?(reporter, comment) }
  end
end
