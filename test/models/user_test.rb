require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires name" do
    user = User.new(email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "requires email" do
    user = User.new(name: "Test", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "role defaults to attendee" do
    user = User.new
    assert_equal "attendee", user.role
  end

  test "admin? returns true for admin role" do
    assert users(:admin).admin?
  end

  test "admin? returns false for attendee role" do
    assert_not users(:attendee).admin?
  end

  test "attendee? returns true for attendee role" do
    assert users(:attendee).attendee?
  end

  test "full_location combines city and country" do
    user = users(:admin)
    assert_equal "Los Angeles, United States", user.full_location
  end

  test "full_location handles nil city" do
    user = User.new(country: "France")
    assert_equal "France", user.full_location
  end

  test "full_location handles nil country" do
    user = User.new(city: "Paris")
    assert_equal "Paris", user.full_location
  end

  test "full_location handles both nil" do
    user = User.new
    assert_equal "", user.full_location
  end

  test "show_on_map defaults to false" do
    user = User.new
    assert_equal false, user.show_on_map
  end
end
