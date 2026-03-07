require "test_helper"

class CohortPolicyTest < ActiveSupport::TestCase
  test "admin can show any cohort" do
    policy = CohortPolicy.new(users(:admin), cohorts(:bali_retreat))
    assert policy.show?
  end

  test "member can show their cohort" do
    policy = CohortPolicy.new(users(:attendee), cohorts(:kabul_retreat))
    assert policy.show?
  end

  test "non-member cannot show cohort" do
    policy = CohortPolicy.new(users(:attendee_two), cohorts(:kabul_retreat))
    assert_not policy.show?
  end

  test "admin can create cohorts" do
    policy = CohortPolicy.new(users(:admin), Cohort.new)
    assert policy.create?
  end

  test "attendee cannot create cohorts" do
    policy = CohortPolicy.new(users(:attendee), Cohort.new)
    assert_not policy.create?
  end

  test "admin can update cohorts" do
    policy = CohortPolicy.new(users(:admin), cohorts(:kabul_retreat))
    assert policy.update?
  end

  test "attendee cannot update cohorts" do
    policy = CohortPolicy.new(users(:attendee), cohorts(:kabul_retreat))
    assert_not policy.update?
  end

  test "admin can destroy cohorts" do
    policy = CohortPolicy.new(users(:admin), cohorts(:kabul_retreat))
    assert policy.destroy?
  end

  test "attendee cannot destroy cohorts" do
    policy = CohortPolicy.new(users(:attendee), cohorts(:kabul_retreat))
    assert_not policy.destroy?
  end

  test "admin can manage members" do
    policy = CohortPolicy.new(users(:admin), cohorts(:kabul_retreat))
    assert policy.manage_members?
  end

  test "attendee cannot manage members" do
    policy = CohortPolicy.new(users(:attendee), cohorts(:kabul_retreat))
    assert_not policy.manage_members?
  end

  test "scope returns all kept cohorts for admin" do
    scope = CohortPolicy::Scope.new(users(:admin), Cohort).resolve
    assert_equal Cohort.kept.count, scope.count
  end

  test "scope returns all kept cohorts for attendee" do
    scope = CohortPolicy::Scope.new(users(:attendee), Cohort).resolve
    assert_equal Cohort.kept.count, scope.count
  end

  test "scope returns all kept cohorts for non-member" do
    scope = CohortPolicy::Scope.new(users(:attendee_two), Cohort).resolve
    assert_equal Cohort.kept.count, scope.count
  end

  test "anyone can view index" do
    policy = CohortPolicy.new(users(:attendee), Cohort.new)
    assert policy.index?
  end

  test "scope excludes soft-deleted cohorts for admin" do
    cohorts(:bali_retreat).discard
    scope = CohortPolicy::Scope.new(users(:admin), Cohort).resolve
    assert_not_includes scope, cohorts(:bali_retreat)
  end

  test "scope excludes soft-deleted cohorts for attendee" do
    cohorts(:kabul_retreat).discard
    scope = CohortPolicy::Scope.new(users(:attendee), Cohort).resolve
    assert_not_includes scope, cohorts(:kabul_retreat)
  end
end
