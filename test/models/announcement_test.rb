require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  test "valid announcement" do
    announcement = Announcement.new(title: "Test", body: "Test body", creator: users(:admin))
    assert announcement.valid?
  end

  test "requires title" do
    announcement = Announcement.new(body: "Test body", creator: users(:admin))
    assert_not announcement.valid?
    assert_includes announcement.errors[:title], "can't be blank"
  end

  test "requires body" do
    announcement = Announcement.new(title: "Test", creator: users(:admin))
    assert_not announcement.valid?
    assert_includes announcement.errors[:body], "can't be blank"
  end

  test "current scope returns only the active announcement" do
    current = Announcement.current
    assert_equal 1, current.count
    assert_equal announcements(:active_announcement), current.first
  end

  test "activating an announcement deactivates others" do
    inactive = announcements(:inactive_announcement)
    inactive.update!(active: true)

    assert inactive.reload.active?
    assert_not announcements(:active_announcement).reload.active?
  end

  test "current scope excludes future-dated active announcements" do
    # Deactivate the current one and activate the scheduled one
    announcements(:active_announcement).update_column(:active, false)
    announcements(:scheduled_announcement).update_column(:active, true)

    assert_empty Announcement.current
  end

  test "scheduled? returns true for active announcement with future published_at" do
    scheduled = announcements(:scheduled_announcement)
    scheduled.update_column(:active, true)

    assert scheduled.scheduled?
  end

  test "scheduled? returns false for active announcement with past published_at" do
    assert_not announcements(:active_announcement).scheduled?
  end

  test "sets published_at to current time when activating without a date" do
    announcement = Announcement.create!(title: "No date", body: "Test", creator: users(:admin), active: true)
    assert_not_nil announcement.published_at
    assert_in_delta Time.current, announcement.published_at, 2.seconds
  end
end
