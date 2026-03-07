require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "requires name" do
    group = Group.new(creator: users(:admin))
    assert_not group.valid?
    assert_includes group.errors[:name], "can't be blank"
  end

  test "valid with name and creator" do
    group = Group.new(name: "Test Group", creator: users(:admin))
    assert group.valid?
  end

  test "creator is automatically added as member" do
    group = Group.create!(name: "New Group", creator: users(:attendee_two))
    assert group.member?(users(:attendee_two))
  end

  test "member? returns true for members" do
    assert groups(:book_club).member?(users(:attendee))
  end

  test "member? returns false for non-members" do
    assert_not groups(:book_club).member?(users(:attendee_two))
  end

  test "creator? returns true for the creator" do
    assert groups(:book_club).creator?(users(:attendee))
  end

  test "creator? returns false for non-creator" do
    assert_not groups(:book_club).creator?(users(:admin))
  end

  test "unread_post_count returns 0 for non-member" do
    assert_equal 0, groups(:book_club).unread_post_count(users(:attendee_two))
  end

  test "unread_post_count counts all non-author posts when posts_last_read_at is nil" do
    group = groups(:book_club)
    user = users(:attendee)
    expected = group.group_posts.where.not(user: user).count
    assert_operator expected, :>, 0
    assert_equal expected, group.unread_post_count(user)
  end

  test "unread_post_count counts only posts after posts_last_read_at" do
    group = groups(:book_club)
    user = users(:attendee)
    membership = group.group_memberships.find_by(user: user)
    membership.update!(posts_last_read_at: 2.hours.ago)

    expected = group.group_posts.where.not(user: user)
                    .where("group_posts.created_at > ?", 2.hours.ago).count
    assert_equal expected, group.unread_post_count(user)
  end

  test "rejects non-image header_image" do
    group = Group.new(name: "Test", creator: users(:admin))
    group.header_image.attach(
      io: StringIO.new("not an image"),
      filename: "test.txt",
      content_type: "text/plain"
    )
    assert_not group.valid?
    assert_includes group.errors[:header_image], "must be a JPEG, PNG, GIF, or WebP"
  end

  test "rejects oversized header_image" do
    group = Group.new(name: "Test", creator: users(:admin))
    group.header_image.attach(
      io: StringIO.new("x" * (11 * 1024 * 1024)),
      filename: "big.jpg",
      content_type: "image/jpeg"
    )
    assert_not group.valid?
    assert_includes group.errors[:header_image], "must be less than 10MB"
  end

  test "destroying group destroys posts" do
    group = groups(:book_club)
    assert group.group_posts.any?
    assert_difference "GroupPost.count", -group.group_posts.count do
      group.destroy
    end
  end
end
