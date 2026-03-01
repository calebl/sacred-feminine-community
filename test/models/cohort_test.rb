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

  # Soft-delete
  test "soft-delete sets discarded_at" do
    cohort = cohorts(:bali_retreat)
    assert_nil cohort.discarded_at
    cohort.discard
    assert_not_nil cohort.reload.discarded_at
    assert cohort.discarded?
  end

  test "soft-deleted cohort is excluded from kept scope" do
    cohort = cohorts(:bali_retreat)
    assert_includes Cohort.kept, cohort
    cohort.discard
    assert_not_includes Cohort.kept, cohort
  end

  test "soft-delete preserves memberships" do
    cohort = cohorts(:kabul_retreat)
    membership_count = cohort.cohort_memberships.count
    assert membership_count > 0
    cohort.discard
    assert_equal membership_count, CohortMembership.where(cohort_id: cohort.id).count
  end

  test "soft-delete preserves chat messages" do
    cohort = cohorts(:kabul_retreat)
    cohort.chat_messages.create!(user: users(:admin), body: "Test message")
    message_count = cohort.chat_messages.count
    cohort.discard
    assert_equal message_count, ChatMessage.where(cohort_id: cohort.id).count
  end

  test "undiscard restores cohort" do
    cohort = cohorts(:bali_retreat)
    cohort.discard
    assert cohort.discarded?
    cohort.undiscard
    assert cohort.kept?
    assert_nil cohort.discarded_at
  end

  # Unread count
  test "unread_count returns 0 with no messages" do
    assert_equal 0, cohorts(:kabul_retreat).unread_count(users(:attendee))
  end

  test "unread_count counts messages after last_read_at" do
    cohort = cohorts(:kabul_retreat)
    membership = cohort.cohort_memberships.find_by(user: users(:attendee))
    membership.update!(last_read_at: 1.hour.ago)

    cohort.chat_messages.create!(user: users(:admin), body: "New group message")

    assert_equal 1, cohort.unread_count(users(:attendee))
  end

  test "unread_count counts all messages when last_read_at is nil" do
    cohort = cohorts(:kabul_retreat)
    cohort.chat_messages.create!(user: users(:admin), body: "First")
    cohort.chat_messages.create!(user: users(:admin), body: "Second")

    assert_equal 2, cohort.unread_count(users(:attendee))
  end

  test "unread_count excludes own messages" do
    cohort = cohorts(:kabul_retreat)
    membership = cohort.cohort_memberships.find_by(user: users(:attendee))
    membership.update!(last_read_at: 1.hour.ago)

    cohort.chat_messages.create!(user: users(:admin), body: "From admin")
    cohort.chat_messages.create!(user: users(:attendee), body: "From self")

    assert_equal 1, cohort.unread_count(users(:attendee))
  end

  test "unread_count returns 0 for non-member" do
    assert_equal 0, cohorts(:kabul_retreat).unread_count(users(:attendee_two))
  end

  # Auditing
  test "creates audit on cohort update" do
    cohort = cohorts(:kabul_retreat)
    cohort.update!(name: "Updated Name")
    assert cohort.audits.where(action: "update").exists?
  end
end
