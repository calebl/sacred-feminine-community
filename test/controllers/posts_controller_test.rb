require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "member can view post" do
    sign_in users(:attendee)
    get cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_response :success
  end

  test "non-member cannot view post" do
    sign_in users(:attendee_two)
    get cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_redirected_to root_path
  end

  test "admin can view any post" do
    sign_in users(:admin)
    get cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_response :success
  end

  test "member can create post" do
    sign_in users(:attendee)
    assert_difference "Post.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
        post: { body: "Some post content" }
      }
    end
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), Post.last)
  end

  test "admin can create post even when not explicitly a member" do
    sign_in users(:admin)
    assert_difference "Post.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
        post: { body: "Admin content" }
      }
    end
  end

  test "non-member cannot create post" do
    sign_in users(:attendee_two)
    assert_no_difference "Post.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
        post: { body: "Content" }
      }
    end
    assert_redirected_to root_path
  end

  test "invalid inline post renders cohort show" do
    sign_in users(:attendee)
    assert_no_difference "Post.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
        inline_feed: "1",
        post: { body: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "author can delete own post" do
    sign_in users(:attendee)
    assert_difference "Post.count", -1 do
      delete cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    end
    assert_redirected_to cohort_path(cohorts(:kabul_retreat), tab: :feed)
  end

  test "admin can delete any post" do
    sign_in users(:admin)
    assert_difference "Post.count", -1 do
      delete cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    end
  end

  test "admin can pin post" do
    sign_in users(:admin)
    post_record = posts(:attendee_post)
    assert_not post_record.pinned?

    patch cohort_post_pin_path(cohorts(:kabul_retreat), post_record)
    assert post_record.reload.pinned?
    assert_redirected_to cohort_path(cohorts(:kabul_retreat), tab: :feed)
  end

  test "admin can unpin post" do
    sign_in users(:admin)
    post_record = posts(:pinned_announcement)
    assert post_record.pinned?

    patch cohort_post_pin_path(cohorts(:kabul_retreat), post_record)
    assert_not post_record.reload.pinned?
  end

  test "attendee cannot pin post" do
    sign_in users(:attendee)
    patch cohort_post_pin_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_redirected_to root_path
  end

  test "author can edit own post" do
    sign_in users(:attendee)
    get edit_cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_response :success
  end

  test "non-author member cannot edit post" do
    sign_in users(:attendee)
    get edit_cohort_post_path(cohorts(:kabul_retreat), posts(:pinned_announcement))
    assert_redirected_to root_path
  end

  test "admin cannot edit another user's post" do
    sign_in users(:admin)
    get edit_cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_redirected_to root_path
  end

  test "author can update own post" do
    sign_in users(:attendee)
    patch cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
      post: { body: "Updated post content" }
    }
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_equal "Updated post content", posts(:attendee_post).reload.body
  end

  test "non-author member cannot update post" do
    sign_in users(:attendee)
    patch cohort_post_path(cohorts(:kabul_retreat), posts(:pinned_announcement)), params: {
      post: { body: "Hacked" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked", posts(:pinned_announcement).reload.body
  end

  test "update with blank body re-renders show with errors" do
    sign_in users(:attendee)
    patch cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
      post: { body: "" }
    }
    assert_response :unprocessable_entity
  end

  test "unauthenticated user cannot access posts" do
    get cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_redirected_to new_user_session_path
  end

  test "viewing post marks it as read" do
    sign_in users(:attendee)
    assert_difference "PostRead.count" do
      get cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    end
  end

  test "inline create redirects to cohort on success" do
    sign_in users(:attendee)
    assert_difference "Post.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
        inline_feed: "1",
        post: { body: "Content here" }
      }
    end
    assert_redirected_to cohort_path(cohorts(:kabul_retreat), tab: :feed)
  end

  test "creating a post with mentions creates mention records" do
    sign_in users(:attendee)
    mentioned = users(:admin)
    assert_difference "Mention.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
        post: { body: "Hello @[#{mentioned.name}](#{mentioned.id})" }
      }
    end
    mention = Mention.last
    assert_equal mentioned, mention.user
    assert_equal users(:attendee), mention.mentioner
    assert_equal "Post", mention.mentionable_type
  end

  test "viewing post marks mention notifications as read" do
    sign_in users(:admin)
    mentioned_post = posts(:attendee_post)
    notification = Notification.create!(
      user: users(:admin),
      actor: users(:attendee),
      event_type: "mention",
      title: "#{users(:attendee).name} mentioned you",
      body: "In a post",
      path: cohort_post_path(cohorts(:kabul_retreat), mentioned_post),
      notifiable_type: "Post",
      notifiable_id: mentioned_post.id
    )
    get cohort_post_path(cohorts(:kabul_retreat), mentioned_post)
    assert notification.reload.read_at.present?
  end

  test "inline create renders cohort show on validation failure" do
    sign_in users(:attendee)
    assert_no_difference "Post.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
        inline_feed: "1",
        post: { body: "" }
      }
    end
    assert_response :unprocessable_entity
    assert_select "[data-controller='inline-post-form']"
  end

  test "cohort show renders post-scoped reply containers" do
    sign_in users(:attendee)
    get cohort_path(cohorts(:kabul_retreat), tab: :feed)
    assert_response :success
    assert_select "#post_comments_for_#{posts(:attendee_post).id}"
  end

  test "cohort show shows reply count with reply text" do
    sign_in users(:attendee)
    get cohort_path(cohorts(:kabul_retreat), tab: :feed)
    assert_response :success
    assert_select "button", text: /\d+ repl(y|ies)/
  end

  test "cohort show displays user avatars on posts" do
    sign_in users(:attendee)
    get cohort_path(cohorts(:kabul_retreat), tab: :feed)
    assert_response :success
    assert_select "div.w-6.h-6.rounded-full", minimum: 1
  end

  test "cohort post show uses post-scoped reply container" do
    sign_in users(:attendee)
    get cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_response :success
    assert_select "#post_comments_for_#{posts(:attendee_post).id}"
  end

  test "cohort post show uses reply terminology" do
    sign_in users(:attendee)
    get cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_response :success
    assert_select "h2", text: /Replies/
  end

  test "inline edit updates cohort post via turbo stream" do
    sign_in users(:attendee)
    patch cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
      inline_edit: "1",
      post: { body: "Inline updated content" }
    }, as: :turbo_stream
    assert_response :success
    assert_equal "Inline updated content", posts(:attendee_post).reload.body
  end

  test "inline edit with blank body returns unprocessable entity for cohort post" do
    sign_in users(:attendee)
    original_body = posts(:attendee_post).body
    patch cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
      inline_edit: "1",
      post: { body: "" }
    }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_equal original_body, posts(:attendee_post).reload.body
  end

  test "updating post text preserves existing photos" do
    sign_in users(:attendee)
    post_record = posts(:attendee_post)

    # Attach a photo to the post
    photo = fixture_file_upload("avatar.png", "image/png")
    post_record.photos.attach(photo)
    assert_equal 1, post_record.photos.count

    # Update the post body without changing photos
    patch cohort_post_path(cohorts(:kabul_retreat), post_record), params: {
      post: { body: "Updated text without touching photos" }
    }

    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), post_record)
    post_record.reload
    assert_equal "Updated text without touching photos", post_record.body
    assert_equal 1, post_record.photos.count, "Photo should still be attached"
  end

  test "updating post can add new photos while keeping existing ones" do
    sign_in users(:attendee)
    post_record = posts(:attendee_post)

    # Attach a photo to the post
    photo1 = fixture_file_upload("avatar.png", "image/png")
    post_record.photos.attach(photo1)
    assert_equal 1, post_record.photos.count

    # Update and add a second photo
    photo2 = fixture_file_upload("avatar.png", "image/png")
    patch cohort_post_path(cohorts(:kabul_retreat), post_record), params: {
      post: { body: "Updated with new photo", photos: [ photo2 ] }
    }

    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), post_record)
    post_record.reload
    assert_equal 2, post_record.photos.count, "Should have both photos"
  end
end
