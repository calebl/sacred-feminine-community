require "test_helper"

class Account::UserPolicyTest < ActiveSupport::TestCase
  setup do
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @admin = users(:admin)
  end

  test "user can update their own email" do
    assert Account::UserPolicy.new(@attendee, @attendee).update_email?
  end

  test "user cannot update another user's email" do
    assert_not Account::UserPolicy.new(@attendee, @attendee_two).update_email?
  end

  test "admin cannot update another user's email via this policy" do
    assert_not Account::UserPolicy.new(@admin, @attendee).update_email?
  end

  test "user can update their own password" do
    assert Account::UserPolicy.new(@attendee, @attendee).update_password?
  end

  test "user cannot update another user's password" do
    assert_not Account::UserPolicy.new(@attendee, @attendee_two).update_password?
  end
end
