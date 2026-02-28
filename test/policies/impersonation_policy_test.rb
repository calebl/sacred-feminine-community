require "test_helper"

class ImpersonationPolicyTest < ActiveSupport::TestCase
  test "admin can create impersonation" do
    policy = ImpersonationPolicy.new(users(:admin), :impersonation)
    assert policy.create?
  end

  test "attendee cannot create impersonation" do
    policy = ImpersonationPolicy.new(users(:attendee), :impersonation)
    assert_not policy.create?
  end

  test "any user can destroy impersonation" do
    policy = ImpersonationPolicy.new(users(:attendee), :impersonation)
    assert policy.destroy?
  end
end
