require "test_helper"

class HelpRequestReplyTest < ActiveSupport::TestCase
  test "valid with body, help_request, and user" do
    reply = HelpRequestReply.new(body: "Here is help", help_request: help_requests(:open_request), user: users(:admin))
    assert reply.valid?
  end

  test "invalid without body" do
    reply = HelpRequestReply.new(help_request: help_requests(:open_request), user: users(:admin))
    assert_not reply.valid?
    assert_includes reply.errors[:body], "can't be blank"
  end

  test "touches help_request on create" do
    request = help_requests(:open_request)
    original_updated_at = request.updated_at

    travel_to 1.minute.from_now do
      HelpRequestReply.create!(body: "Update", help_request: request, user: users(:admin))
    end

    assert request.reload.updated_at > original_updated_at
  end
end
