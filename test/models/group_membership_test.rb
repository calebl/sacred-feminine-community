require "test_helper"

class GroupMembershipTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "joining a group notifies the existing members" do
    group = groups.book_club # attendee (creator) and admin are members
    joiner = users.admin_two

    GroupMembership.create!(group: group, user: joiner)

    recipient_ids = new_member_jobs.map { |j| j["arguments"].last["user_id"] }

    assert_includes recipient_ids, users.attendee.id
    assert_includes recipient_ids, users.admin.id
  end

  test "joining a group does not notify the joining member" do
    group = groups.book_club
    joiner = users.admin_two

    GroupMembership.create!(group: group, user: joiner)

    recipient_ids = new_member_jobs.map { |j| j["arguments"].last["user_id"] }
    assert_not_includes recipient_ids, joiner.id
  end

  test "new_member notification carries the actor, group name, and group path" do
    group = groups.book_club
    joiner = users.admin_two

    GroupMembership.create!(group: group, user: joiner)

    args = new_member_jobs.first["arguments"].last

    assert_equal joiner.id, args["actor_id"]
    assert_equal joiner.name, args["title"]
    assert_equal "Joined #{group.name}", args["body"]
    assert_equal "/groups/#{group.id}", args["path"]
  end

  test "creating a group does not notify anyone (creator is the only member)" do
    group = Group.create!(name: "Solo Group", creator: users.attendee)

    recipient_ids = new_member_jobs.map { |j| j["arguments"].last["user_id"] }
    assert_empty recipient_ids
  end

  private

  def new_member_jobs
    enqueued_jobs.select do |j|
      j["job_class"] == "CreateNotificationJob" &&
        j["arguments"].last["event_type"] == "new_member"
    end
  end
end
