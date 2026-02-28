require "test_helper"

class CohortTest < ActiveSupport::TestCase
  test "requires name" do
    cohort = Cohort.new(creator: users(:admin))
    assert_not cohort.valid?
    assert_includes cohort.errors[:name], "can't be blank"
  end

  test "member? returns true for a member" do
    assert cohorts(:kabul_retreat).member?(users(:attendee))
  end

  test "member? returns false for a non-member" do
    assert_not cohorts(:bali_retreat).member?(users(:attendee))
  end

  test "has many members through cohort_memberships" do
    cohort = cohorts(:kabul_retreat)
    assert_includes cohort.members, users(:admin)
    assert_includes cohort.members, users(:attendee)
  end

  test "belongs to creator" do
    assert_equal users(:admin), cohorts(:kabul_retreat).creator
  end

  test "rejects invalid header image content type" do
    cohort = cohorts(:kabul_retreat)
    cohort.header_image.attach(io: StringIO.new("fake"), filename: "test.txt", content_type: "text/plain")
    assert_not cohort.valid?
    assert_includes cohort.errors[:header_image], "must be a JPEG, PNG, GIF, or WebP"
  end

  test "rejects header image over 10MB" do
    cohort = cohorts(:kabul_retreat)
    cohort.header_image.attach(io: StringIO.new("x" * 11.megabytes), filename: "big.png", content_type: "image/png")
    assert_not cohort.valid?
    assert_includes cohort.errors[:header_image], "must be less than 10MB"
  end

  test "accepts valid header image" do
    cohort = cohorts(:kabul_retreat)
    cohort.header_image.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    assert cohort.valid?
  end
end
