require "test_helper"

class Admin::UserPolicyTest < ActiveSupport::TestCase
  test "admin can view removed users index" do
    policy = Admin::UserPolicy.new(users(:admin), User)
    assert policy.index?
  end

  test "attendee cannot view removed users index" do
    policy = Admin::UserPolicy.new(users(:attendee), User)
    assert_not policy.index?
  end

  test "admin can destroy users" do
    policy = Admin::UserPolicy.new(users(:admin), users(:attendee))
    assert policy.destroy?
  end

  test "attendee cannot destroy users" do
    policy = Admin::UserPolicy.new(users(:attendee), users(:attendee_two))
    assert_not policy.destroy?
  end

  test "admin can restore users" do
    policy = Admin::UserPolicy.new(users(:admin), users(:attendee))
    assert policy.update?
  end

  test "attendee cannot restore users" do
    policy = Admin::UserPolicy.new(users(:attendee), users(:attendee_two))
    assert_not policy.update?
  end
end
