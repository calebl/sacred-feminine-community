require "test_helper"

class Admin::Users::UserPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
  end

  test "admin can update another user's role" do
    assert Admin::Users::UserPolicy.new(@admin, @attendee).update_role?
  end

  test "attendee cannot update another user's role" do
    assert_not Admin::Users::UserPolicy.new(@attendee, @admin).update_role?
  end

  test "admin can copy invite link" do
    assert Admin::Users::UserPolicy.new(@admin, users(:pending_invite)).copy_invite_link?
  end

  test "attendee cannot copy invite link" do
    assert_not Admin::Users::UserPolicy.new(@attendee, users(:pending_invite)).copy_invite_link?
  end
end
