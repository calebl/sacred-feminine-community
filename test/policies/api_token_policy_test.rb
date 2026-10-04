require "test_helper"

class ApiTokenPolicyTest < ActiveSupport::TestCase
  setup do
    @own = ApiToken.issue!(user: users.attendee, device_name: "iPhone")
    @other = ApiToken.issue!(user: users.admin, device_name: "iPhone")
  end

  test "a member may revoke only their own devices" do
    assert ApiTokenPolicy.new(users.attendee, @own).destroy?
    assert_not ApiTokenPolicy.new(users.attendee, @other).destroy?
    assert_not ApiTokenPolicy.new(users.admin, @own).destroy?
  end

  test "scope is limited to the member's devices" do
    assert_equal [ @own ], ApiTokenPolicy::Scope.new(users.attendee, ApiToken).resolve.to_a
  end
end
