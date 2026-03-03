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
      user: users(:attendee_two),
      cohort: cohorts(:bali_retreat)
    )
    assert membership.valid?
  end

  # Auditing
  test "creates audit on membership creation" do
    membership = CohortMembership.create!(user: users(:attendee_two), cohort: cohorts(:kabul_retreat))
    assert_equal 1, membership.audits.count
    assert_equal "create", membership.audits.last.action
  end

  test "audit is associated with cohort" do
    membership = CohortMembership.create!(user: users(:attendee_two), cohort: cohorts(:kabul_retreat))
    audit = membership.audits.last
    assert_equal "Cohort", audit.associated_type
    assert_equal cohorts(:kabul_retreat).id, audit.associated_id
  end
end
