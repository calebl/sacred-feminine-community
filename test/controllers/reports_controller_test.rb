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
    assert_equal "Report: post", request.subject
    assert_match feed_post_path(feed_post), request.body
    assert_match "Spam", request.body
    assert_not_includes request.body, feed_post.body
    notification_bodies = enqueued_jobs
      .select { |job| job["job_class"] == "CreateNotificationJob" }
      .map { |job| job["arguments"].first["body"] }
    assert_not_empty notification_bodies
    assert notification_bodies.all? { |body| body == "#{@reporter.name}: Report: post" }
    assert_redirected_to help_request_path(request)
  end

  test "a second report of the same item appends its reason to the open one" do
    reportable = users.attendee_two
    reportable.update!(bio: "Profile details")
    post reports_path, params: { report: { reportable_type: "User", reportable_id: reportable.id, reason: "First reason" } }
    request = HelpRequest.order(:id).last
    assert_not_includes request.body, "Profile details"

    request.help_request_replies.create!(user: users.admin, body: "We reviewed this")
    assert_not_includes HelpRequest.needs_admin_attention, request

    assert_no_difference -> { HelpRequest.count } do
      assert_enqueued_jobs 2, only: CreateNotificationJob do
        post reports_path, params: { report: { reportable_type: "User", reportable_id: reportable.id, reason: "New reason" } }
      end
    end

    assert_match "First reason", request.reload.body
    assert_match "Additional reason:\nNew reason", request.body
    assert_includes HelpRequest.needs_admin_attention, request
    assert_equal request, HelpRequest.newest_first.first
  end

  test "reports a direct message without copying its text" do
    message = conversations.admin_attendee_convo.direct_messages.create!(sender: users.admin, body: "Something unkind")

    post reports_path, params: { report: { reportable_type: "DirectMessage", reportable_id: message.id } }

    request = HelpRequest.order(:id).last
    assert_not_includes request.body, "Something unkind"
    assert_includes request.body, help_request_reported_direct_message_path(request)

    sign_in users.admin_two
    get help_request_path(request)
    assert_select "a[href='#{help_request_reported_direct_message_path(request)}']", text: "View reported content"
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

  test "reports a comment without copying its text" do
    comment = post_comments.admin_comment

    assert_difference -> { HelpRequest.count }, 1 do
      post reports_path, params: { report: { reportable_type: "PostComment", reportable_id: comment.id } }
    end

    request = HelpRequest.order(:id).last
    assert_not_includes request.body, comment.body
  end

  test "comment report links reveal and highlight the exact nested comment" do
    sign_in users.admin
    comments = [
      post_comments.nested_reply,
      group_post_comments.nested_group_reply,
      feed_post_comments.nested_feed_reply
    ]

    comments.each do |comment|
      path = ContentReport.path_for(comment)
      assert_equal "#{ActionView::RecordIdentifier.dom_id(comment)}", URI.parse(path).fragment

      get path.split("#").first

      assert_response :success
      assert_select "##{ActionView::RecordIdentifier.dom_id(comment)}.ring-2"
      ancestor = comment.parent
      while ancestor
        assert_select "#replies_for_#{ancestor.id}.hidden", count: 0
        ancestor = ancestor.parent
      end
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
