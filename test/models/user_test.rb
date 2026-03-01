require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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

  test "full_location combines city, state, and country" do
    user = users(:admin)
    assert_equal "Los Angeles, California, United States", user.full_location
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

  test "enqueues geocode job when city changes" do
    user = users(:attendee)
    assert_enqueued_with(job: GeocodeUserJob) do
      user.update!(city: "Berlin")
    end
  end

  test "enqueues geocode job when country changes" do
    user = users(:attendee)
    assert_enqueued_with(job: GeocodeUserJob) do
      user.update!(country: "Germany")
    end
  end

  test "enqueues geocode job when state changes" do
    user = users(:attendee)
    assert_enqueued_with(job: GeocodeUserJob) do
      user.update!(state: "Ile-de-France")
    end
  end

  test "rejects invalid avatar content type" do
    user = users(:attendee)
    user.avatar.attach(io: StringIO.new("fake"), filename: "test.txt", content_type: "text/plain")
    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be a JPEG, PNG, GIF, or WebP"
  end

  test "rejects avatar over 5MB" do
    user = users(:attendee)
    user.avatar.attach(io: StringIO.new("x" * 6.megabytes), filename: "big.png", content_type: "image/png")
    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be less than 5MB"
  end
end
