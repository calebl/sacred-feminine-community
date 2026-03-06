require "test_helper"

class FeedPostCommentsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can add comment" do
    sign_in users(:attendee)
    assert_difference "FeedPostComment.count" do
      post feed_post_feed_post_comments_path(feed_posts(:public_post)), params: {
        feed_post_comment: { body: "Great post!" }
      }
    end
    assert_redirected_to feed_post_path(feed_posts(:public_post))
  end

  test "authenticated user can add comment via turbo_stream" do
    sign_in users(:attendee)
    assert_difference "FeedPostComment.count" do
      post feed_post_feed_post_comments_path(feed_posts(:public_post)),
        params: { feed_post_comment: { body: "Great post!" } },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "blank comment redirects with alert" do
    sign_in users(:attendee)
    assert_no_difference "FeedPostComment.count" do
      post feed_post_feed_post_comments_path(feed_posts(:public_post)), params: {
        feed_post_comment: { body: "" }
      }
    end
    assert_redirected_to feed_post_path(feed_posts(:public_post))
    assert_equal "Reply could not be saved.", flash[:alert]
  end

  test "author can delete own comment" do
    sign_in users(:attendee)
    comment = feed_post_comments(:attendee_feed_comment)
    assert_difference "FeedPostComment.count", -1 do
      delete feed_post_feed_post_comment_path(feed_posts(:pinned_feed_post), comment)
    end
    assert_redirected_to feed_post_path(feed_posts(:pinned_feed_post))
  end

  test "admin can delete any comment" do
    sign_in users(:admin)
    comment = feed_post_comments(:attendee_feed_comment)
    assert_difference "FeedPostComment.count", -1 do
      delete feed_post_feed_post_comment_path(feed_posts(:pinned_feed_post), comment)
    end
  end

  test "unauthenticated user cannot comment" do
    assert_no_difference "FeedPostComment.count" do
      post feed_post_feed_post_comments_path(feed_posts(:public_post)), params: {
        feed_post_comment: { body: "Not logged in" }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "user can reply to a comment" do
    sign_in users(:attendee)
    parent = feed_post_comments(:admin_feed_comment)
    assert_difference "FeedPostComment.count" do
      post feed_post_feed_post_comments_path(feed_posts(:public_post)), params: {
        feed_post_comment: { body: "Great reply!", parent_id: parent.id }
      }
    end
    reply = FeedPostComment.last
    assert_equal parent, reply.parent
    assert_redirected_to feed_post_path(feed_posts(:public_post))
  end

  test "reply via turbo_stream targets parent replies container" do
    sign_in users(:attendee)
    parent = feed_post_comments(:admin_feed_comment)
    assert_difference "FeedPostComment.count" do
      post feed_post_feed_post_comments_path(feed_posts(:public_post)),
        params: { feed_post_comment: { body: "Turbo reply!", parent_id: parent.id } },
        as: :turbo_stream
    end
    assert_response :success
    assert_includes response.body, "replies_for_#{parent.id}"
  end

  test "deleting comment with replies cascades" do
    sign_in users(:admin)
    parent = feed_post_comments(:admin_feed_comment)
    assert_difference "FeedPostComment.count", -3 do
      delete feed_post_feed_post_comment_path(feed_posts(:public_post), parent)
    end
  end

  test "top-level comment via turbo_stream targets post-scoped container" do
    sign_in users(:attendee)
    post_record = feed_posts(:public_post)
    post feed_post_feed_post_comments_path(post_record),
      params: { feed_post_comment: { body: "Inline reply!" } },
      as: :turbo_stream
    assert_response :success
    assert_includes response.body, "post_comments_for_#{post_record.id}"
  end
end
