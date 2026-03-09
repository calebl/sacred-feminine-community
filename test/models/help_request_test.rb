require "test_helper"

class HelpRequestTest < ActiveSupport::TestCase
  test "valid with subject, body, and user" do
    request = HelpRequest.new(subject: "Need help", body: "Details here", user: users(:attendee))
    assert request.valid?
  end

  test "invalid without subject" do
    request = HelpRequest.new(body: "Details", user: users(:attendee))
    assert_not request.valid?
    assert_includes request.errors[:subject], "can't be blank"
  end

  test "invalid without body" do
    request = HelpRequest.new(subject: "Help", user: users(:attendee))
    assert_not request.valid?
    assert_includes request.errors[:body], "can't be blank"
  end

  test "defaults to open status" do
    request = HelpRequest.create!(subject: "Test", body: "Body", user: users(:attendee))
    assert request.open?
  end

  test "can be closed" do
    request = help_requests(:open_request)
    request.closed!
    assert request.closed?
  end

  test "newest_first scope orders by created_at desc" do
    old = HelpRequest.create!(subject: "Old", body: "Old body", user: users(:attendee), created_at: 2.days.ago)
    recent = HelpRequest.create!(subject: "Recent", body: "Recent body", user: users(:attendee), created_at: 1.hour.ago)

    results = HelpRequest.newest_first
    assert results.index(recent) < results.index(old)
  end

  test "has many replies" do
    request = help_requests(:open_request)
    assert_includes request.help_request_replies, help_request_replies(:admin_reply)
  end

  test "needs_admin_attention includes open requests without admin replies" do
    request = HelpRequest.create!(subject: "Unanswered", body: "Waiting", user: users(:attendee))
    assert_includes HelpRequest.needs_admin_attention, request
  end

  test "needs_admin_attention excludes requests with admin replies" do
    # open_request has an admin reply via fixtures
    assert_not_includes HelpRequest.needs_admin_attention, help_requests(:open_request)
  end

  test "needs_admin_attention excludes closed requests" do
    assert_not_includes HelpRequest.needs_admin_attention, help_requests(:closed_request)
  end

  test "destroying request destroys replies" do
    request = help_requests(:open_request)
    reply_count = request.help_request_replies.count
    assert reply_count > 0

    assert_difference "HelpRequestReply.count", -reply_count do
      request.destroy
    end
  end
end
