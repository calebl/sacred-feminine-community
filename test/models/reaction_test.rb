require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  setup do
    @post = posts(:attendee_post)
    @admin = users(:admin)
    @attendee = users(:attendee)
  end

  test "valid with all attributes" do
    reaction = Reaction.new(reactable: @post, user: users(:attendee_two), emoji: "👍")
    assert reaction.valid?
  end

  test "requires emoji" do
    reaction = Reaction.new(reactable: @post, user: users(:attendee_two))
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "can't be blank"
  end

  test "rejects invalid emoji" do
    reaction = Reaction.new(reactable: @post, user: users(:attendee_two), emoji: "💀")
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "is not included in the list"
  end

  test "allows each valid emoji" do
    Reaction::ALLOWED_EMOJIS.each do |emoji|
      reaction = Reaction.new(reactable: feed_posts(:public_post), user: users(:attendee_two), emoji: emoji)
      Reaction.where(reactable: feed_posts(:public_post), user: users(:attendee_two)).delete_all
      assert reaction.valid?, "#{emoji} should be valid"
    end
  end

  test "prevents duplicate reaction by same user on same item" do
    Reaction.create!(reactable: feed_posts(:pinned_feed_post), user: users(:attendee_two), emoji: "👍")
    duplicate = Reaction.new(reactable: feed_posts(:pinned_feed_post), user: users(:attendee_two), emoji: "❤️")
    assert_not duplicate.valid?
  end

  test "allows same user to react to different items" do
    r1 = Reaction.new(reactable: @post, user: users(:attendee_two), emoji: "👍")
    r2 = Reaction.new(reactable: feed_posts(:public_post), user: users(:attendee_two), emoji: "👍")
    assert r1.valid?
    assert r2.valid?
  end

  test "grouped_reactions returns emoji counts" do
    grouped = @post.grouped_reactions
    assert grouped.is_a?(Hash)
    assert grouped.values.all? { |v| v.positive? }
  end

  test "reaction_by returns user reaction" do
    reaction = @post.reaction_by(@admin)
    assert_not_nil reaction
    assert_equal @admin, reaction.user
  end

  test "reaction_by returns nil when no reaction" do
    reaction = @post.reaction_by(users(:attendee_two))
    assert_nil reaction
  end
end
