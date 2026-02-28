require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:attendee)
    @record = users(:admin)
    @policy = ApplicationPolicy.new(@user, @record)
  end

  test "denies index by default" do
    assert_not @policy.index?
  end

  test "denies show by default" do
    assert_not @policy.show?
  end

  test "denies create by default" do
    assert_not @policy.create?
  end

  test "denies update by default" do
    assert_not @policy.update?
  end

  test "denies destroy by default" do
    assert_not @policy.destroy?
  end

  test "new delegates to create" do
    assert_equal @policy.create?, @policy.new?
  end

  test "edit delegates to update" do
    assert_equal @policy.update?, @policy.edit?
  end
end
