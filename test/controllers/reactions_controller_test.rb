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

  test "destroy toggles reaction off" do
    reaction = reactions(:admin_thumbs_up_post)
    sign_in users(:admin)
    assert_difference "Reaction.count", -1 do
      delete reaction_path(reaction)
    end
  end

  test "update switches reaction emoji" do
    reaction = reactions(:admin_thumbs_up_post)
    sign_in users(:admin)
    assert_no_difference "Reaction.count" do
      patch reaction_path(reaction), params: { emoji: "❤️" }
    end
    assert_equal "❤️", reaction.reload.emoji
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

  test "cannot update another users reaction" do
    reaction = reactions(:admin_thumbs_up_post)
    sign_in users(:attendee)
    assert_no_difference "Reaction.count" do
      patch reaction_path(reaction), params: { emoji: "❤️" }
    end
    assert_response :not_found
  end

  test "cannot destroy another users reaction" do
    reaction = reactions(:admin_thumbs_up_post)
    sign_in users(:attendee)
    assert_no_difference "Reaction.count", -1 do
      delete reaction_path(reaction)
    end
    assert_response :not_found
  end
end
