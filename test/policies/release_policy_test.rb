require "test_helper"

class ReleasePolicyTest < ActiveSupport::TestCase
  test "admin can view the release index" do
    assert ReleasePolicy.new(users(:admin), Release).index?
  end

  test "attendee cannot view the release index" do
    assert_not ReleasePolicy.new(users(:attendee), Release).index?
  end
end
