require "test_helper"

class HelpRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @help_request = help_requests(:open_request)
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
end
