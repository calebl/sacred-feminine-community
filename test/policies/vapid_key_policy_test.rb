require "test_helper"

class VapidKeyPolicyTest < ActiveSupport::TestCase
  test "any authenticated user can view the VAPID public key" do
    assert VapidKeyPolicy.new(users(:attendee), :vapid).show?
    assert VapidKeyPolicy.new(users(:admin), :vapid).show?
  end
end
