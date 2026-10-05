require "test_helper"

class HelpRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users.admin
    @attendee = users.attendee
    @attendee_two = users.attendee_two
    @help_request = help_requests.open_request
  end

  # Index

  test "attendee sees only their own requests" do
    sign_in @attendee
    get help_requests_path
    assert_response :success
    assert_select "h2", text: @help_request.subject
  end

  test "admin sees all requests" do
    sign_in @admin
    get help_requests_path
    assert_response :success
  end

  test "index defaults to open requests" do
    sign_in @attendee
    get help_requests_path
    assert_response :success
    assert_select "h2", text: help_requests.open_request.subject
    assert_select "h2", text: help_requests.closed_request.subject, count: 0
  end

  test "index with status=closed shows closed requests" do
    sign_in @attendee
    get help_requests_path(status: :closed)
    assert_response :success
    assert_select "h2", text: help_requests.closed_request.subject
    assert_select "h2", text: help_requests.open_request.subject, count: 0
  end

  test "unauthenticated user is redirected" do
    get help_requests_path
    assert_response :redirect
  end

  # Show

  test "owner can view their request" do
    sign_in @attendee
    get help_request_path(@help_request)
    assert_response :success
  end

  test "admin can view any request" do
    sign_in @admin
    get help_request_path(@help_request)
    assert_response :success
  end

  test "non-owner cannot view request" do
    sign_in @attendee_two
    get help_request_path(@help_request)
    assert_redirected_to root_path
  end

  test "removed reported profile is shown as unavailable" do
    report = HelpRequest.create!(user: @attendee, reportable: @attendee_two, subject: "Report: profile", body: "Reason")
    @attendee_two.discard!
    sign_in @admin

    get help_request_path(report)

    assert_select "a[href='#{profile_path(@attendee_two)}']", count: 0
    assert_select "span", text: "This item is no longer available to you."
  end

  test "reports in archived containers are shown as unavailable" do
    reportables = [
      posts.attendee_post,
      post_comments.admin_comment,
      group_posts.book_club_post,
      group_post_comments.admin_group_comment
    ]
    reports = reportables.map do |reportable|
      HelpRequest.create!(user: @attendee, reportable: reportable, subject: "Report: content", body: "Reason")
    end
    cohorts.kabul_retreat.discard!
    groups.book_club.discard!
    sign_in @admin

    reports.zip(reportables).each do |report, reportable|
      get help_request_path(report)

      assert_select "a[href='#{ContentReport.path_for(reportable)}']", count: 0
      assert_select "span", text: "This item is no longer available to you."
    end
  end

  test "reported cohort content is unavailable after membership is lost" do
    reportable = posts.pinned_announcement
    report = HelpRequest.create!(user: @attendee, reportable: reportable, subject: "Report: post", body: "Reason")
    cohort_memberships.attendee_in_kabul.destroy!
    sign_in @attendee

    get help_request_path(report)

    assert_select "a[href='#{ContentReport.path_for(reportable)}']", count: 0
    assert_select "span", text: "This item is no longer available to you."
  end

  test "reported posts and their comments are unavailable after the post author becomes hidden" do
    viewer = users.women_only_member
    viewer.update!(cohort_gender_privacy: :all_members)
    comment = feed_posts.male_member_feed_post.feed_post_comments.create!(user: @admin, body: "Visible author reply")
    reportables = [ posts.male_member_post, group_posts.male_member_group_post, feed_posts.male_member_feed_post, comment ]
    reports = reportables.map do |reportable|
      HelpRequest.create!(user: viewer, reportable: reportable, subject: "Report: content", body: "Reason")
    end
    viewer.update!(cohort_gender_privacy: :women_only)
    sign_in viewer

    reports.zip(reportables).each do |report, reportable|
      path = ContentReport.path_for(reportable)
      get help_request_path(report)
      assert_select "a[href='#{path}']", count: 0
      assert_select "span", text: "This item is no longer available to you."

      get path.split("#").first
      assert_redirected_to root_path
    end
  end

  test "reported comment is unavailable after its author becomes hidden" do
    viewer = users.women_only_member
    viewer.update!(cohort_gender_privacy: :all_members)
    comment = feed_post_comments.male_member_feed_reply
    report = HelpRequest.create!(user: viewer, reportable: comment, subject: "Report: comment", body: "Reason")
    viewer.update!(cohort_gender_privacy: :women_only)
    sign_in viewer

    get help_request_path(report)

    assert_select "a[href='#{ContentReport.path_for(comment)}']", count: 0
    assert_select "span", text: "This item is no longer available to you."
  end

  # New

  test "attendee can access new request form" do
    sign_in @attendee
    get new_help_request_path
    assert_response :success
  end

  # Create

  test "attendee can create a help request" do
    sign_in @attendee
    assert_difference "HelpRequest.count" do
      post help_requests_path, params: { help_request: { subject: "New issue", body: "Details here" } }
    end
    assert_redirected_to help_request_path(HelpRequest.last)
  end

  test "create with invalid params renders form" do
    sign_in @attendee
    assert_no_difference "HelpRequest.count" do
      post help_requests_path, params: { help_request: { subject: "", body: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "creating a request enqueues admin notifications" do
    sign_in @attendee
    assert_enqueued_jobs 2, only: CreateNotificationJob do
      post help_requests_path, params: { help_request: { subject: "Help!", body: "Need assistance" } }
    end
  end

  test "creating a request enqueues notifications with correct notifiable" do
    sign_in @attendee
    post help_requests_path, params: { help_request: { subject: "Test", body: "Body" } }
    help_request = HelpRequest.last

    job = enqueued_jobs.find { |j| j["job_class"] == "CreateNotificationJob" }
    args = job["arguments"].first
    assert_equal "HelpRequest", args["notifiable_type"]
    assert_equal help_request.id, args["notifiable_id"]
  end
end
