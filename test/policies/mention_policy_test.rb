require "test_helper"

class MentionPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @cohort = cohorts(:kabul_retreat)
    @post = @cohort.posts.create!(body: "Hello", user: @attendee)
  end

  test "mentioned user can see their mention" do
    mention = Mention.create!(mentionable: @post, user: @admin, mentioner: @attendee)
    assert MentionPolicy.new(@admin, mention).show?
  end

  test "other users cannot see mention" do
    mention = Mention.create!(mentionable: @post, user: @admin, mentioner: @attendee)
    assert_not MentionPolicy.new(@attendee_two, mention).show?
  end

  test "admin can see any mention" do
    mention = Mention.create!(mentionable: @post, user: @attendee, mentioner: @attendee_two)
    assert MentionPolicy.new(@admin, mention).show?
  end

  test "scope returns only user's own mentions" do
    Mention.create!(mentionable: @post, user: @admin, mentioner: @attendee)
    post2 = @cohort.posts.create!(body: "World", user: @admin)
    Mention.create!(mentionable: post2, user: @attendee, mentioner: @admin)

    admin_mentions = MentionPolicy::Scope.new(@admin, Mention).resolve
    assert admin_mentions.all? { |m| m.user_id == @admin.id }

    attendee_mentions = MentionPolicy::Scope.new(@attendee, Mention).resolve
    assert attendee_mentions.all? { |m| m.user_id == @attendee.id }
  end
end
