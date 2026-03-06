require "test_helper"

class FeedPostsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can view feed index" do
    sign_in users(:attendee)
    get feed_posts_path
    assert_response :success
  end

  test "feed index preserves post formatting with whitespace-pre-wrap" do
    sign_in users(:attendee)
    get feed_posts_path
    assert_response :success
    assert_select "div.whitespace-pre-wrap", minimum: 1
  end

  test "unauthenticated user cannot access feed" do
    get feed_posts_path
    assert_redirected_to new_user_session_path
  end

  test "authenticated user can view feed post" do
    sign_in users(:attendee)
    get feed_post_path(feed_posts(:public_post))
    assert_response :success
  end

  test "any authenticated user can view any feed post" do
    sign_in users(:attendee_two)
    get feed_post_path(feed_posts(:public_post))
    assert_response :success
  end

  test "authenticated user can create feed post" do
    sign_in users(:attendee)
    assert_difference "FeedPost.count" do
      post feed_posts_path, params: {
        feed_post: { body: "My first public post" }
      }
    end
    assert_redirected_to feed_post_path(FeedPost.last)
  end

  test "inline create redirects to feed index on success" do
    sign_in users(:attendee)
    assert_difference "FeedPost.count" do
      post feed_posts_path, params: {
        inline_feed: "1",
        feed_post: { body: "Inline post content" }
      }
    end
    assert_redirected_to feed_posts_path
  end

  test "inline create renders index on validation failure" do
    sign_in users(:attendee)
    assert_no_difference "FeedPost.count" do
      post feed_posts_path, params: {
        inline_feed: "1",
        feed_post: { body: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "author can delete own feed post" do
    sign_in users(:attendee)
    assert_difference "FeedPost.count", -1 do
      delete feed_post_path(feed_posts(:attendee_feed_post))
    end
    assert_redirected_to feed_posts_path
  end

  test "admin can delete any feed post" do
    sign_in users(:admin)
    assert_difference "FeedPost.count", -1 do
      delete feed_post_path(feed_posts(:attendee_feed_post))
    end
  end

  test "non-author non-admin cannot delete feed post" do
    sign_in users(:attendee_two)
    assert_no_difference "FeedPost.count" do
      delete feed_post_path(feed_posts(:attendee_feed_post))
    end
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot create feed post" do
    assert_no_difference "FeedPost.count" do
      post feed_posts_path, params: {
        feed_post: { body: "Not logged in" }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "author can edit own feed post" do
    sign_in users(:attendee)
    get edit_feed_post_path(feed_posts(:attendee_feed_post))
    assert_response :success
  end

  test "non-author non-admin cannot edit feed post" do
    sign_in users(:attendee_two)
    get edit_feed_post_path(feed_posts(:attendee_feed_post))
    assert_redirected_to root_path
  end

  test "author can update own feed post" do
    sign_in users(:attendee)
    patch feed_post_path(feed_posts(:attendee_feed_post)), params: {
      feed_post: { body: "Updated content" }
    }
    assert_redirected_to feed_post_path(feed_posts(:attendee_feed_post))
    assert_equal "Updated content", feed_posts(:attendee_feed_post).reload.body
  end

  test "non-author non-admin cannot update feed post" do
    sign_in users(:attendee_two)
    patch feed_post_path(feed_posts(:attendee_feed_post)), params: {
      feed_post: { body: "Hacked" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked", feed_posts(:attendee_feed_post).reload.body
  end

  test "update with blank body re-renders show with errors" do
    sign_in users(:attendee)
    patch feed_post_path(feed_posts(:attendee_feed_post)), params: {
      feed_post: { body: "" }
    }
    assert_response :unprocessable_entity
  end

  test "viewing feed post marks it as read" do
    sign_in users(:attendee)
    assert_difference "FeedPostRead.count" do
      get feed_post_path(feed_posts(:public_post))
    end
  end
end
