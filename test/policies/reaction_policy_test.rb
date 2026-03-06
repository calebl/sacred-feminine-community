require "test_helper"

class ReactionPolicyTest < ActiveSupport::TestCase
  # Cohort post reactions
  test "cohort member can create reaction on cohort post" do
    reaction = Reaction.new(reactable: posts(:attendee_post), emoji: "👍")
    assert ReactionPolicy.new(users(:attendee), reaction).create?
  end

  test "admin can create reaction on any cohort post" do
    reaction = Reaction.new(reactable: posts(:attendee_post), emoji: "👍")
    assert ReactionPolicy.new(users(:admin), reaction).create?
  end

  test "non-member cannot create reaction on cohort post" do
    reaction = Reaction.new(reactable: posts(:attendee_post), emoji: "👍")
    assert_not ReactionPolicy.new(users(:attendee_two), reaction).create?
  end

  # Cohort post comment reactions
  test "cohort member can react to cohort post comment" do
    reaction = Reaction.new(reactable: post_comments(:admin_comment), emoji: "❤️")
    assert ReactionPolicy.new(users(:attendee), reaction).create?
  end

  test "non-member cannot react to cohort post comment" do
    reaction = Reaction.new(reactable: post_comments(:admin_comment), emoji: "❤️")
    assert_not ReactionPolicy.new(users(:attendee_two), reaction).create?
  end

  # Feed post reactions
  test "any authenticated user can create reaction on feed post" do
    reaction = Reaction.new(reactable: feed_posts(:public_post), emoji: "👍")
    assert ReactionPolicy.new(users(:attendee_two), reaction).create?
  end

  # Feed post comment reactions
  test "any user can react to feed post comment" do
    reaction = Reaction.new(reactable: feed_post_comments(:admin_feed_comment), emoji: "❤️")
    assert ReactionPolicy.new(users(:attendee_two), reaction).create?
  end

  # Group post reactions
  test "group member can create reaction on group post" do
    reaction = Reaction.new(reactable: group_posts(:book_club_post), emoji: "👍")
    assert ReactionPolicy.new(users(:attendee), reaction).create?
  end

  test "non-member cannot create reaction on group post" do
    reaction = Reaction.new(reactable: group_posts(:book_club_post), emoji: "👍")
    assert_not ReactionPolicy.new(users(:attendee_two), reaction).create?
  end

  # Group post comment reactions
  test "group member can react to group post comment" do
    reaction = Reaction.new(reactable: group_post_comments(:admin_group_comment), emoji: "🔥")
    assert ReactionPolicy.new(users(:attendee), reaction).create?
  end

  test "non-member cannot react to group post comment" do
    reaction = Reaction.new(reactable: group_post_comments(:admin_group_comment), emoji: "🔥")
    assert_not ReactionPolicy.new(users(:attendee_two), reaction).create?
  end

  # Update
  test "owner can update own reaction" do
    assert ReactionPolicy.new(users(:admin), reactions(:admin_thumbs_up_post)).update?
  end

  test "user cannot update another users reaction" do
    assert_not ReactionPolicy.new(users(:attendee_two), reactions(:admin_thumbs_up_post)).update?
  end

  test "non-member cannot update own reaction on cohort post" do
    reaction = reactions(:attendee_heart_post)
    # attendee_two is not a member of the cohort
    assert_not ReactionPolicy.new(users(:attendee_two), reaction).update?
  end

  # Destroy
  test "user can destroy own reaction" do
    assert ReactionPolicy.new(users(:admin), reactions(:admin_thumbs_up_post)).destroy?
  end

  test "user cannot destroy another user reaction" do
    assert_not ReactionPolicy.new(users(:attendee), reactions(:admin_thumbs_up_post)).destroy?
  end
end
