require "test_helper"

class HelpRequestReplyPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @request = help_requests(:open_request)
  end

  test "admin can reply to any request" do
    reply = @request.help_request_replies.build(user: @admin)
    assert HelpRequestReplyPolicy.new(@admin, reply).create?
  end

  test "request owner can reply" do
    reply = @request.help_request_replies.build(user: @attendee)
    assert HelpRequestReplyPolicy.new(@attendee, reply).create?
  end

  test "non-owner attendee cannot reply" do
    reply = @request.help_request_replies.build(user: @attendee_two)
    assert_not HelpRequestReplyPolicy.new(@attendee_two, reply).create?
  end
end
