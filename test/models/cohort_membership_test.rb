require "test_helper"

class CohortMembershipTest < ActiveSupport::TestCase
  test "prevents duplicate memberships" do
    duplicate = CohortMembership.new(
      user: users(:admin),
      cohort: cohorts(:kabul_retreat)
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "is already a member"
  end

  test "allows same user in different cohorts" do
    membership = CohortMembership.new(
      user: users(:attendee),
      cohort: cohorts(:bali_retreat)
    )
    assert membership.valid?
  end
end
