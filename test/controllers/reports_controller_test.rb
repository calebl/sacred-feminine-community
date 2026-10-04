require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reporter = users.attendee
    sign_in @reporter
  end

  test "shows the report form for someone else's post" do
    get new_report_path(reportable_type: "FeedPost", reportable_id: feed_posts.public_post.id)
    assert_response :success
    assert_select "input[type=submit][value='Send Report']"
  end

  test "creates a help request that links to the reported post" do
    feed_post = feed_posts.public_post

    assert_difference -> { HelpRequest.count }, 1 do
      post reports_path, params: { report: { reportable_type: "FeedPost", reportable_id: feed_post.id, reason: "Spam" } }
    end

    request = HelpRequest.order(:id).last
    assert_equal @reporter, request.user
    assert_equal feed_post, request.reportable
    assert_match "Report: post by #{feed_post.user.name}", request.subject
    assert_match feed_post_path(feed_post), request.body
    assert_match "Spam", request.body
    assert_redirected_to help_request_path(request)
  end

  test "a second report of the same item appends its reason to the open one" do
    reportable = users.attendee_two
    post reports_path, params: { report: { reportable_type: "User", reportable_id: reportable.id, reason: "First reason" } }
    request = HelpRequest.order(:id).last

    assert_no_difference -> { HelpRequest.count } do
      post reports_path, params: { report: { reportable_type: "User", reportable_id: reportable.id, reason: "New reason" } }
    end

    assert_match "First reason", request.reload.body
    assert_match "Additional reason:\nNew reason", request.body
  end

  test "stores a direct message snapshot encrypted and shows it only to admins" do
    message = conversations.admin_attendee_convo.direct_messages.create!(sender: users.admin, body: "Something unkind")

    post reports_path, params: { report: { reportable_type: "DirectMessage", reportable_id: message.id } }

    request = HelpRequest.order(:id).last
    assert_not_includes request.body, "Something unkind"
    assert_equal "Something unkind", request.reported_snapshot
    assert_not_includes request.read_attribute_before_type_cast(:reported_snapshot), "Something unkind"

    get help_request_path(request)
    assert_select "body", text: /Something unkind/, count: 0

    sign_in users.admin
    get help_request_path(request)
    assert_select "body", text: /Something unkind/
  end

  test "a new report is created when the earlier report is closed" do
    reportable = users.attendee_two
    post reports_path, params: { report: { reportable_type: "User", reportable_id: reportable.id, reason: "First reason" } }
    first_request = HelpRequest.order(:id).last
    first_request.closed!

    assert_difference -> { HelpRequest.count }, 1 do
      post reports_path, params: { report: { reportable_type: "User", reportable_id: reportable.id, reason: "Later reason" } }
    end

    assert_not_includes first_request.reload.body, "Later reason"
    assert_includes HelpRequest.order(:id).last.body, "Later reason"
  end

  test "reports a comment" do
    comment = post_comments.admin_comment

    assert_difference -> { HelpRequest.count }, 1 do
      post reports_path, params: { report: { reportable_type: "PostComment", reportable_id: comment.id } }
    end
  end

  test "cannot report your own content" do
    assert_no_difference -> { HelpRequest.count } do
      post reports_path, params: { report: { reportable_type: "FeedPost", reportable_id: feed_posts.attendee_feed_post.id } }
    end
  end

  test "cannot report a message in someone else's conversation" do
    message = conversations.admin_attendee_convo.direct_messages.create!(sender: users.admin, body: "Private")
    sign_in users.attendee_two

    assert_no_difference -> { HelpRequest.count } do
      post reports_path, params: { report: { reportable_type: "DirectMessage", reportable_id: message.id } }
    end
  end

  test "rejects unknown types" do
    post reports_path, params: { report: { reportable_type: "Faq", reportable_id: faqs.active_faq.id } }
    assert_response :not_found
  end

  test "admins see a link to the reported item" do
    post reports_path, params: { report: { reportable_type: "FeedPost", reportable_id: feed_posts.public_post.id } }
    request = HelpRequest.order(:id).last

    sign_in users.admin
    get help_request_path(request)
    assert_select "a[href='#{feed_post_path(feed_posts.public_post)}']", text: "View reported content"
  end

  test "report links show on other members' content but not your own" do
    get profile_path(users.attendee_two)
    assert_select "a", text: "Report"

    get profile_path(@reporter)
    assert_select "a", text: "Report", count: 0
  end
end
