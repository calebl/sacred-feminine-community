require "test_helper"

class HelpRequests::StatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users.admin
    @attendee = users.attendee
    @help_request = help_requests.open_request
  end

  test "admin can close a request" do
    sign_in @admin
    patch help_request_status_path(@help_request), params: { status: :closed }
    assert_redirected_to help_request_path(@help_request)
    assert @help_request.reload.closed?
  end

  test "admin can reopen a request" do
    sign_in @admin
    @help_request.closed!
    patch help_request_status_path(@help_request), params: { status: :open }
    assert_redirected_to help_request_path(@help_request)
    assert @help_request.reload.open?
  end

  test "admin cannot reopen a report when another report for the item is open" do
    reportable = users.attendee_two
    closed_report = HelpRequest.create!(
      user: @attendee,
      reportable: reportable,
      subject: "Older report",
      body: "Older reason",
      status: :closed
    )
    HelpRequest.create!(user: @attendee, reportable: reportable, subject: "Open report", body: "New reason")
    sign_in @admin

    patch help_request_status_path(closed_report), params: { status: :open }

    assert_redirected_to help_request_path(closed_report)
    assert_equal "Another report for this item is already open. Close it before reopening this report.", flash[:alert]
    assert closed_report.reload.closed?
  end

  test "attendee cannot change status" do
    sign_in @attendee
    patch help_request_status_path(@help_request), params: { status: :closed }
    assert_redirected_to root_path
    assert @help_request.reload.open?
  end

  test "admin passing an invalid status is rejected" do
    sign_in @admin
    patch help_request_status_path(@help_request), params: { status: "not_a_status" }
    assert_redirected_to help_request_path(@help_request)
    assert_equal "Invalid status.", flash[:alert]
    assert @help_request.reload.open?
  end
end
