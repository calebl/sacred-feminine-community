require "test_helper"

class HelpRequestReplyTest < ActiveSupport::TestCase
  test "valid with body, help_request, and user" do
    reply = HelpRequestReply.new(body: "Here is help", help_request: help_requests.open_request, user: users.admin)
    assert reply.valid?
  end

  test "invalid without body" do
    reply = HelpRequestReply.new(help_request: help_requests.open_request, user: users.admin)
    assert_not reply.valid?
    assert_includes reply.errors[:body], "can't be blank"
  end

  test "touches help_request on create" do
    request = help_requests.open_request
    original_updated_at = request.updated_at

    travel_to 1.minute.from_now do
      HelpRequestReply.create!(body: "Update", help_request: request, user: users.admin)
    end

    assert request.reload.updated_at > original_updated_at
  end

  test "does not move help request activity backward" do
    request = help_requests.open_request
    reply = HelpRequestReply.create!(body: "Earlier activity", help_request: request, user: users.admin)
    later_activity = reply.created_at + 1.minute
    request.update_column(:updated_at, later_activity)

    reply.send(:touch_help_request)

    assert_equal later_activity, request.reload.updated_at
  end
end
