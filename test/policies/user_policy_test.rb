require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "any user can view a profile" do
    policy = UserPolicy.new(users(:attendee), users(:admin))
    assert policy.show_profile?
  end

  test "user can edit own profile" do
    user = users(:attendee)
    policy = UserPolicy.new(user, user)
    assert policy.edit_profile?
  end

  test "user cannot edit another user profile" do
    policy = UserPolicy.new(users(:attendee), users(:admin))
    assert_not policy.edit_profile?
  end

  test "user can update own profile" do
    user = users(:attendee)
    policy = UserPolicy.new(user, user)
    assert policy.update_profile?
  end

  test "user cannot update another user profile" do
    policy = UserPolicy.new(users(:attendee), users(:admin))
    assert_not policy.update_profile?
  end

  test "scope returns only kept users" do
    users(:attendee_two).discard
    scope = UserPolicy::Scope.new(users(:attendee), User).resolve
    assert_equal User.kept.count, scope.count
    assert_not_includes scope, users(:attendee_two)
  end
end
