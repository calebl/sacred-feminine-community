require "test_helper"

class HelpRequests::StatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @help_request = help_requests(:open_request)
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

  test "attendee cannot change status" do
    sign_in @attendee
    patch help_request_status_path(@help_request), params: { status: :closed }
    assert_redirected_to root_path
    assert @help_request.reload.open?
  end
end
