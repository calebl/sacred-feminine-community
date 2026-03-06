require "test_helper"

class ReactionsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can add reaction to feed post" do
    sign_in users(:attendee_two)
    assert_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "FeedPost", reactable_id: feed_posts(:public_post).id, emoji: "🔥"
      }
    end
  end

  test "reaction via turbo_stream returns stream response" do
    sign_in users(:attendee_two)
    post reactions_path,
      params: { reactable_type: "FeedPost", reactable_id: feed_posts(:public_post).id, emoji: "🔥" },
      as: :turbo_stream
    assert_response :success
    assert_includes response.body, "reactions_for_feed_post_#{feed_posts(:public_post).id}"
  end

  test "clicking same emoji toggles reaction off" do
    sign_in users(:admin)
    assert_difference "Reaction.count", -1 do
      post reactions_path, params: {
        reactable_type: "Post", reactable_id: posts(:attendee_post).id, emoji: "👍"
      }
    end
  end

  test "clicking different emoji switches reaction" do
    sign_in users(:admin)
    assert_no_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "Post", reactable_id: posts(:attendee_post).id, emoji: "❤️"
      }
    end
    assert_equal "❤️", Reaction.find_by(
      reactable: posts(:attendee_post), user: users(:admin)
    ).emoji
  end

  test "cohort member can react to cohort post" do
    sign_in users(:attendee)
    assert_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "Post", reactable_id: posts(:bali_post).id, emoji: "🙏"
      }
    end
  end

  test "non-member cannot react to cohort post" do
    sign_in users(:attendee_two)
    assert_no_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "Post", reactable_id: posts(:attendee_post).id, emoji: "👍"
      }
    end
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "unauthenticated user cannot react" do
    assert_no_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "FeedPost", reactable_id: feed_posts(:public_post).id, emoji: "👍"
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "invalid reactable_type returns not found" do
    sign_in users(:attendee)
    post reactions_path, params: {
      reactable_type: "User", reactable_id: users(:attendee).id, emoji: "👍"
    }
    assert_response :not_found
  end

  test "can react to a post comment" do
    sign_in users(:admin)
    assert_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "PostComment",
        reactable_id: post_comments(:admin_comment).id,
        emoji: "😂"
      }
    end
  end

  test "can react to a feed post comment" do
    sign_in users(:attendee)
    assert_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "FeedPostComment",
        reactable_id: feed_post_comments(:admin_feed_comment).id,
        emoji: "🙏"
      }
    end
  end

  test "can react to a group post comment" do
    sign_in users(:admin)
    assert_difference "Reaction.count" do
      post reactions_path, params: {
        reactable_type: "GroupPostComment",
        reactable_id: group_post_comments(:admin_group_comment).id,
        emoji: "🔥"
      }
    end
  end
end
