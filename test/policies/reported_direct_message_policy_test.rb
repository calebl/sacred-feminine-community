require "test_helper"

class ReportedDirectMessagePolicyTest < ActiveSupport::TestCase
  setup do
    @message = conversations.admin_attendee_convo.direct_messages.create!(sender: users.attendee, body: "Reported words")
    @report = HelpRequest.create!(
      user: users.admin,
      reportable: @message,
      subject: "Report: message",
      body: "Reason: harmful"
    )
  end

  test "admins can view a message through its open report" do
    assert ReportedDirectMessagePolicy.new(users.admin_two, @report).show?
  end

  test "non-admins and closed or unrelated requests cannot view a reported message" do
    assert_not ReportedDirectMessagePolicy.new(users.attendee, @report).show?

    @report.closed!
    assert_not ReportedDirectMessagePolicy.new(users.admin_two, @report).show?

    unrelated = help_requests.open_request
    assert_not ReportedDirectMessagePolicy.new(users.admin_two, unrelated).show?
  end
end
