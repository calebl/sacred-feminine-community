require "test_helper"

class MentionTest < ActiveSupport::TestCase
  setup do
    @cohort = cohorts(:kabul_retreat)
    @admin = users(:admin)
    @attendee = users(:attendee)
    @post = @cohort.posts.create!(body: "Hello", user: @attendee)
  end

  test "valid with all attributes" do
    mention = Mention.new(mentionable: @post, user: @admin, mentioner: @attendee)
    assert mention.valid?
  end

  test "requires user" do
    mention = Mention.new(mentionable: @post, mentioner: @attendee)
    assert_not mention.valid?
  end

  test "requires mentioner" do
    mention = Mention.new(mentionable: @post, user: @admin)
    assert_not mention.valid?
  end

  test "prevents duplicate mention of same user on same mentionable" do
    Mention.create!(mentionable: @post, user: @admin, mentioner: @attendee)
    duplicate = Mention.new(mentionable: @post, user: @admin, mentioner: @attendee)
    assert_not duplicate.valid?
  end

  test "unread scope returns only unread mentions" do
    read = Mention.create!(mentionable: @post, user: @admin, mentioner: @attendee, read_at: Time.current)
    post2 = @cohort.posts.create!(body: "World", user: @attendee)
    unread = Mention.create!(mentionable: post2, user: @admin, mentioner: @attendee)

    assert_includes Mention.unread, unread
    assert_not_includes Mention.unread, read
  end

  test "read! marks mention as read" do
    mention = Mention.create!(mentionable: @post, user: @admin, mentioner: @attendee)
    assert_nil mention.read_at
    mention.read!
    assert_not_nil mention.reload.read_at
  end

  test "read! does not update already read mention" do
    mention = Mention.create!(mentionable: @post, user: @admin, mentioner: @attendee, read_at: 1.hour.ago)
    original_read_at = mention.read_at
    mention.read!
    assert_equal original_read_at, mention.reload.read_at
  end
end
