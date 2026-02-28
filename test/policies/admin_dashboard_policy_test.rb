require "test_helper"

class AdminDashboardPolicyTest < ActiveSupport::TestCase
  test "admin can view dashboard" do
    policy = AdminDashboardPolicy.new(users(:admin), :admin_dashboard)
    assert policy.show?
  end

  test "attendee cannot view dashboard" do
    policy = AdminDashboardPolicy.new(users(:attendee), :admin_dashboard)
    assert_not policy.show?
  end
end
