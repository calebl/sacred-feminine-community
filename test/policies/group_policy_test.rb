require "test_helper"

class GroupPolicyTest < ActiveSupport::TestCase
  # view_content?
  test "member can view content" do
    assert GroupPolicy.new(users.attendee, groups.book_club).view_content?
  end

  test "non-member cannot view content" do
    assert_not GroupPolicy.new(users.attendee_two, groups.book_club).view_content?
  end

  test "admin can view content of group they have not joined" do
    assert GroupPolicy.new(users.admin, groups.reading_group).view_content?
  end

  # update?
  test "creator can update their group" do
    assert GroupPolicy.new(users.attendee, groups.book_club).update?
  end

  test "admin can update any group" do
    assert GroupPolicy.new(users.admin, groups.book_club).update?
  end

  test "non-creator member cannot update group" do
    assert_not GroupPolicy.new(users.attendee_two, groups.book_club).update?
  end

  # destroy?
  test "creator can destroy their group" do
    assert GroupPolicy.new(users.attendee, groups.book_club).destroy?
  end

  test "admin can destroy any group" do
    assert GroupPolicy.new(users.admin, groups.book_club).destroy?
  end

  test "non-creator member cannot destroy group" do
    assert_not GroupPolicy.new(users.attendee_two, groups.book_club).destroy?
  end

  # join?
  test "non-member can join" do
    assert GroupPolicy.new(users.attendee_two, groups.book_club).join?
  end

  test "member cannot join again" do
    assert_not GroupPolicy.new(users.attendee, groups.book_club).join?
  end

  # leave?
  test "member can leave" do
    assert GroupPolicy.new(users.attendee, groups.book_club).leave?
  end

  test "non-member cannot leave" do
    assert_not GroupPolicy.new(users.attendee_two, groups.book_club).leave?
  end
end
