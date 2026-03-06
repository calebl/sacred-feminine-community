require "test_helper"

class FeedPostPolicyTest < ActiveSupport::TestCase
  test "any authenticated user can view feed" do
    assert FeedPostPolicy.new(users(:attendee), FeedPost).index?
  end

  test "any authenticated user can show feed post" do
    assert FeedPostPolicy.new(users(:attendee), feed_posts(:public_post)).show?
    assert FeedPostPolicy.new(users(:attendee_two), feed_posts(:public_post)).show?
  end

  test "any authenticated user can create feed post" do
    post = FeedPost.new
    assert FeedPostPolicy.new(users(:attendee), post).create?
    assert FeedPostPolicy.new(users(:attendee_two), post).create?
  end

  test "author can destroy own feed post" do
    assert FeedPostPolicy.new(users(:attendee), feed_posts(:attendee_feed_post)).destroy?
  end

  test "admin can destroy any feed post" do
    assert FeedPostPolicy.new(users(:admin), feed_posts(:attendee_feed_post)).destroy?
  end

  test "non-author non-admin cannot destroy feed post" do
    assert_not FeedPostPolicy.new(users(:attendee_two), feed_posts(:attendee_feed_post)).destroy?
  end

  test "author can update own feed post" do
    assert FeedPostPolicy.new(users(:attendee), feed_posts(:attendee_feed_post)).update?
  end

  test "admin cannot update another user's feed post" do
    assert_not FeedPostPolicy.new(users(:admin), feed_posts(:attendee_feed_post)).update?
  end

  test "non-author non-admin cannot update feed post" do
    assert_not FeedPostPolicy.new(users(:attendee_two), feed_posts(:attendee_feed_post)).update?
  end

  test "admin can pin" do
    assert FeedPostPolicy.new(users(:admin), feed_posts(:public_post)).pin?
  end

  test "attendee cannot pin" do
    assert_not FeedPostPolicy.new(users(:attendee), feed_posts(:public_post)).pin?
  end
end
