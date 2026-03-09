require "test_helper"

class HelpRequestRepliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @help_request = help_requests(:open_request)
  end

  test "admin can reply to a request" do
    sign_in @admin
    assert_difference "HelpRequestReply.count" do
      post help_request_help_request_replies_path(@help_request), params: { help_request_reply: { body: "Here is help" } }
    end
    assert_redirected_to help_request_path(@help_request)
  end

  test "request owner can reply" do
    sign_in @attendee
    assert_difference "HelpRequestReply.count" do
      post help_request_help_request_replies_path(@help_request), params: { help_request_reply: { body: "Thanks!" } }
    end
    assert_redirected_to help_request_path(@help_request)
  end

  test "non-owner attendee cannot reply" do
    sign_in @attendee_two
    assert_no_difference "HelpRequestReply.count" do
      post help_request_help_request_replies_path(@help_request), params: { help_request_reply: { body: "Nope" } }
    end
    assert_redirected_to root_path
  end

  test "invalid reply renders show page" do
    sign_in @admin
    assert_no_difference "HelpRequestReply.count" do
      post help_request_help_request_replies_path(@help_request), params: { help_request_reply: { body: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "admin reply notifies request owner" do
    sign_in @admin
    assert_enqueued_jobs 1, only: CreateNotificationJob do
      post help_request_help_request_replies_path(@help_request), params: { help_request_reply: { body: "Helping you" } }
    end
  end

  test "attendee reply notifies admins who have replied" do
    sign_in @attendee
    # open_request has one admin reply (from :admin), so only that admin is notified
    assert_enqueued_jobs 1, only: CreateNotificationJob do
      post help_request_help_request_replies_path(@help_request), params: { help_request_reply: { body: "Follow up question" } }
    end
  end

  test "attendee reply does not notify admins who have not replied" do
    # Create a request with no admin replies
    request_without_replies = HelpRequest.create!(subject: "New", body: "Body", user: @attendee)
    sign_in @attendee
    assert_enqueued_jobs 0, only: CreateNotificationJob do
      post help_request_help_request_replies_path(request_without_replies), params: { help_request_reply: { body: "Hello?" } }
    end
  end
end
