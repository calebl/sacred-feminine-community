require "test_helper"

class AnnouncementPolicyTest < ActiveSupport::TestCase
  test "admin can create announcements" do
    policy = AnnouncementPolicy.new(users(:admin), Announcement.new)
    assert policy.create?
  end

  test "attendee cannot create announcements" do
    policy = AnnouncementPolicy.new(users(:attendee), Announcement.new)
    assert_not policy.create?
  end

  test "admin can update announcements" do
    policy = AnnouncementPolicy.new(users(:admin), announcements(:active_announcement))
    assert policy.update?
  end

  test "attendee cannot update announcements" do
    policy = AnnouncementPolicy.new(users(:attendee), announcements(:active_announcement))
    assert_not policy.update?
  end

  test "admin can destroy announcements" do
    policy = AnnouncementPolicy.new(users(:admin), announcements(:active_announcement))
    assert policy.destroy?
  end

  test "attendee cannot destroy announcements" do
    policy = AnnouncementPolicy.new(users(:attendee), announcements(:active_announcement))
    assert_not policy.destroy?
  end

  test "admin can index announcements" do
    policy = AnnouncementPolicy.new(users(:admin), Announcement.new)
    assert policy.index?
  end

  test "attendee cannot index announcements" do
    policy = AnnouncementPolicy.new(users(:attendee), Announcement.new)
    assert_not policy.index?
  end
end
