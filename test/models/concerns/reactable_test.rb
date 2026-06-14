require "test_helper"

class ReactableTest < ActiveSupport::TestCase
  test "post has reactions association" do
    post = posts(:attendee_post)
    assert_respond_to post, :reactions
  end

  test "feed_post has reactions association" do
    post = feed_posts(:public_post)
    assert_respond_to post, :reactions
  end

  test "group_post has reactions association" do
    post = group_posts(:book_club_post)
    assert_respond_to post, :reactions
  end

  test "post_comment has reactions association" do
    comment = post_comments(:admin_comment)
    assert_respond_to comment, :reactions
  end

  test "feed_post_comment has reactions association" do
    comment = feed_post_comments(:admin_feed_comment)
    assert_respond_to comment, :reactions
  end

  test "group_post_comment has reactions association" do
    comment = group_post_comments(:admin_group_comment)
    assert_respond_to comment, :reactions
  end

  test "destroying reactable destroys associated reactions" do
    post = feed_posts(:public_post)
    assert post.reactions.any?
    assert_difference "Reaction.count", -post.reactions.count do
      post.destroy
    end
  end

  test "grouped_reactions returns hash of emoji to count" do
    post = posts(:attendee_post)
    grouped = post.grouped_reactions
    assert grouped.is_a?(Hash)
    grouped.each do |emoji, count|
      assert_includes Reaction::ALLOWED_EMOJIS, emoji
      assert count.positive?
    end
  end

  test "reactor_names_by_emoji groups reactor names under each emoji" do
    post = posts(:attendee_post)
    names = post.reactor_names_by_emoji

    assert_equal [ users(:admin).name ], names["👍"]
    assert_equal [ users(:attendee).name ], names["❤️"]
  end

  test "reactor_names_by_emoji collects multiple names for the same emoji" do
    post = posts(:attendee_post)
    post.reactions.create!(user: users(:admin_two), emoji: "❤️")

    names = post.reactor_names_by_emoji

    assert_equal [ users(:attendee).name, users(:admin_two).name ].sort, names["❤️"].sort
  end
end
