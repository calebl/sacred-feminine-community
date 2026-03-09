require "test_helper"

class HelpRequestPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @request = help_requests(:open_request)
  end

  test "any user can list help requests" do
    assert HelpRequestPolicy.new(@attendee, HelpRequest).index?
  end

  test "owner can view their request" do
    assert HelpRequestPolicy.new(@attendee, @request).show?
  end

  test "admin can view any request" do
    assert HelpRequestPolicy.new(@admin, @request).show?
  end

  test "non-owner attendee cannot view request" do
    assert_not HelpRequestPolicy.new(@attendee_two, @request).show?
  end

  test "any user can create a request" do
    assert HelpRequestPolicy.new(@attendee, HelpRequest.new).create?
  end

  test "admin can update request status" do
    assert HelpRequestPolicy.new(@admin, @request).update?
  end

  test "attendee cannot update request status" do
    assert_not HelpRequestPolicy.new(@attendee, @request).update?
  end

  test "scope returns only own requests for attendee" do
    scope = HelpRequestPolicy::Scope.new(@attendee, HelpRequest).resolve
    scope.each do |request|
      assert_equal @attendee, request.user
    end
  end

  test "scope returns all requests for admin" do
    scope = HelpRequestPolicy::Scope.new(@admin, HelpRequest).resolve
    assert_equal HelpRequest.count, scope.count
  end
end
