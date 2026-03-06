require "test_helper"

class PostPolicyTest < ActiveSupport::TestCase
  test "member can show post in their cohort" do
    assert PostPolicy.new(users(:attendee), posts(:attendee_post)).show?
  end

  test "non-member cannot show post" do
    assert_not PostPolicy.new(users(:attendee_two), posts(:attendee_post)).show?
  end

  test "admin can show any post" do
    assert PostPolicy.new(users(:admin), posts(:attendee_post)).show?
  end

  test "member can create post" do
    post = Post.new(cohort: cohorts(:kabul_retreat))
    assert PostPolicy.new(users(:attendee), post).create?
  end

  test "admin can create post even when not a member" do
    post = Post.new(cohort: cohorts(:kabul_retreat))
    assert PostPolicy.new(users(:admin), post).create?
  end

  test "non-member cannot create post" do
    post = Post.new(cohort: cohorts(:kabul_retreat))
    assert_not PostPolicy.new(users(:attendee_two), post).create?
  end

  test "author can destroy own post" do
    assert PostPolicy.new(users(:attendee), posts(:attendee_post)).destroy?
  end

  test "admin can destroy any post" do
    assert PostPolicy.new(users(:admin), posts(:attendee_post)).destroy?
  end

  test "non-author member cannot destroy post" do
    assert_not PostPolicy.new(users(:attendee), posts(:pinned_announcement)).destroy?
  end

  test "author can update own post" do
    assert PostPolicy.new(users(:attendee), posts(:attendee_post)).update?
  end

  test "admin cannot update another user's post" do
    assert_not PostPolicy.new(users(:admin), posts(:attendee_post)).update?
  end

  test "non-author member cannot update post" do
    assert_not PostPolicy.new(users(:attendee), posts(:pinned_announcement)).update?
  end

  test "admin can pin" do
    assert PostPolicy.new(users(:admin), posts(:attendee_post)).pin?
  end

  test "attendee cannot pin" do
    assert_not PostPolicy.new(users(:attendee), posts(:attendee_post)).pin?
  end
end
