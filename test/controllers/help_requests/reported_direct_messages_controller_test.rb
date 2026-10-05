require "test_helper"

class HelpRequests::ReportedDirectMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @message = conversations.admin_attendee_convo.direct_messages.create!(sender: users.attendee, body: "Reported words")
    @other_message = conversations.admin_attendee_convo.direct_messages.create!(sender: users.admin, body: "Unreported words")
    @report = HelpRequest.create!(
      user: users.admin,
      reportable: @message,
      subject: "Report: message",
      body: "Reason: harmful"
    )
  end

  test "admin sees only the message attached to the open report" do
    sign_in users.admin_two

    get help_request_reported_direct_message_path(@report)

    assert_response :success
    assert_select "strong", text: users.attendee.name
    assert_match "Reported words", response.body
    assert_no_match "Unreported words", response.body
    assert_select "a[href='#{conversation_path(@message.conversation)}']", count: 0
  end

  test "admin without a message report is refused" do
    sign_in users.admin_two

    get help_request_reported_direct_message_path(help_requests.open_request)

    assert_redirected_to root_path
  end

  test "non-admin is refused even when they own the report" do
    @report.update!(user: users.attendee)
    sign_in users.attendee

    get help_request_reported_direct_message_path(@report)

    assert_redirected_to root_path
  end

  test "deleted reported message is shown as unavailable" do
    @message.destroy!
    sign_in users.admin_two

    get help_request_reported_direct_message_path(@report)

    assert_response :success
    assert_select "p", text: "This reported message is no longer available."

    get help_request_path(@report)
    assert_select "a[href='#{help_request_reported_direct_message_path(@report)}']", count: 0
    assert_select "span", text: "This item is no longer available to you."
  end
end
