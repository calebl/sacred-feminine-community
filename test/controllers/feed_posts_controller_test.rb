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

  test "feed index renders post-scoped reply containers" do
    sign_in users(:attendee)
    get feed_posts_path
    assert_response :success
    assert_select "#post_comments_for_#{feed_posts(:public_post).id}"
  end

  test "feed index shows reply count with reply text" do
    sign_in users(:attendee)
    get feed_posts_path
    assert_response :success
    assert_select "button", text: /\d+ repl(y|ies)/
  end

  test "feed index displays user avatars on posts" do
    sign_in users(:attendee)
    get feed_posts_path
    assert_response :success
    assert_select "div.w-6.h-6.rounded-full", minimum: 1
  end

  test "feed show uses post-scoped reply container" do
    sign_in users(:attendee)
    get feed_post_path(feed_posts(:public_post))
    assert_response :success
    assert_select "#post_comments_for_#{feed_posts(:public_post).id}"
  end

  test "feed show uses reply terminology" do
    sign_in users(:attendee)
    get feed_post_path(feed_posts(:public_post))
    assert_response :success
    assert_select "h2", text: /Replies/
  end

  test "inline edit updates post via turbo stream" do
    sign_in users(:attendee)
    patch feed_post_path(feed_posts(:attendee_feed_post)), params: {
      inline_edit: "1",
      feed_post: { body: "Inline updated content" }
    }, as: :turbo_stream
    assert_response :success
    assert_equal "Inline updated content", feed_posts(:attendee_feed_post).reload.body
  end

  test "inline edit with blank body returns unprocessable entity" do
    sign_in users(:attendee)
    original_body = feed_posts(:attendee_feed_post).body
    patch feed_post_path(feed_posts(:attendee_feed_post)), params: {
      inline_edit: "1",
      feed_post: { body: "" }
    }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_equal original_body, feed_posts(:attendee_feed_post).reload.body
  end

  test "updating post text preserves existing photos" do
    sign_in users(:attendee)
    post_record = feed_posts(:attendee_feed_post)

    # Attach a photo to the post
    photo = fixture_file_upload("avatar.png", "image/png")
    post_record.photos.attach(photo)
    assert_equal 1, post_record.photos.count

    # Update the post body without changing photos
    patch feed_post_path(post_record), params: {
      feed_post: { body: "Updated text without touching photos" }
    }

    assert_redirected_to feed_post_path(post_record)
    post_record.reload
    assert_equal "Updated text without touching photos", post_record.body
    assert_equal 1, post_record.photos.count, "Photo should still be attached"
  end

  test "updating post can add new photos while keeping existing ones" do
    sign_in users(:attendee)
    post_record = feed_posts(:attendee_feed_post)

    # Attach a photo to the post
    photo1 = fixture_file_upload("avatar.png", "image/png")
    post_record.photos.attach(photo1)
    assert_equal 1, post_record.photos.count

    # Update and add a second photo
    photo2 = fixture_file_upload("avatar.png", "image/png")
    patch feed_post_path(post_record), params: {
      feed_post: { body: "Updated with new photo", photos: [ photo2 ] }
    }

    assert_redirected_to feed_post_path(post_record)
    post_record.reload
    assert_equal 2, post_record.photos.count, "Should have both photos"
  end

  test "removing existing photo via remove_photos param still works" do
    sign_in users(:attendee)
    post_record = feed_posts(:attendee_feed_post)

    # Attach a photo to the post
    photo = fixture_file_upload("avatar.png", "image/png")
    post_record.photos.attach(photo)
    photo_id = post_record.photos.first.id

    # Remove the photo via remove_photos param
    patch feed_post_path(post_record), params: {
      feed_post: { body: "Text update" },
      remove_photos: [ photo_id ]
    }

    assert_redirected_to feed_post_path(post_record)
    post_record.reload
    assert_equal 0, post_record.photos.count, "Photo should be removed"
  end
end
