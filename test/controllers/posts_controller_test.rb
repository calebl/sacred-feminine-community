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

  test "new with existing draft redirects to edit" do
    sign_in users(:attendee)
    draft = posts(:attendee_draft)
    get new_cohort_post_path(cohorts(:kabul_retreat))
    assert_redirected_to edit_cohort_post_path(cohorts(:kabul_retreat), draft)
  end

  test "new without existing draft creates draft and redirects to edit" do
    sign_in users(:admin)
    assert_difference "Post.count" do
      get new_cohort_post_path(cohorts(:kabul_retreat))
    end
    new_draft = Post.last
    assert new_draft.draft?
    assert_redirected_to edit_cohort_post_path(cohorts(:kabul_retreat), new_draft)
  end

  test "non-member cannot access new post form" do
    sign_in users(:attendee_two)
    get new_cohort_post_path(cohorts(:kabul_retreat))
    assert_redirected_to root_path
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

  test "invalid post re-renders form" do
    sign_in users(:attendee)
    assert_no_difference "Post.count" do
      post cohort_posts_path(cohorts(:kabul_retreat)), params: {
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

    patch pin_cohort_post_path(cohorts(:kabul_retreat), post_record)
    assert post_record.reload.pinned?
    assert_redirected_to cohort_path(cohorts(:kabul_retreat), tab: :feed)
  end

  test "admin can unpin post" do
    sign_in users(:admin)
    post_record = posts(:pinned_announcement)
    assert post_record.pinned?

    patch pin_cohort_post_path(cohorts(:kabul_retreat), post_record)
    assert_not post_record.reload.pinned?
  end

  test "attendee cannot pin post" do
    sign_in users(:attendee)
    patch pin_cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_redirected_to root_path
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

  test "edit shows draft form" do
    sign_in users(:attendee)
    get edit_cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_draft))
    assert_response :success
  end

  test "edit redirects to show for published posts" do
    sign_in users(:attendee)
    get edit_cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
  end

  test "update saves draft fields" do
    sign_in users(:attendee)
    draft = posts(:attendee_draft)
    patch cohort_post_path(cohorts(:kabul_retreat), draft), params: {
      post: { body: "Updated draft body" }
    }
    assert_redirected_to edit_cohort_post_path(cohorts(:kabul_retreat), draft)
    draft.reload
    assert_equal "Updated draft body", draft.body
    assert draft.draft?
  end

  test "update with publish publishes the post" do
    sign_in users(:attendee)
    draft = posts(:attendee_draft)
    patch cohort_post_path(cohorts(:kabul_retreat), draft), params: {
      publish: "1",
      post: { body: "Published body" }
    }
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), draft)
    draft.reload
    assert_not draft.draft?
    assert_equal "Published body", draft.body
  end

  test "publish fails without body" do
    sign_in users(:attendee)
    draft = posts(:attendee_draft)
    patch cohort_post_path(cohorts(:kabul_retreat), draft), params: {
      publish: "1",
      post: { body: "" }
    }
    assert_response :unprocessable_entity
    draft.reload
    assert draft.draft?
  end

  test "drafts do not appear in cohort feed" do
    sign_in users(:attendee)
    get cohort_path(cohorts(:kabul_retreat), tab: :feed)
    assert_response :success
    assert_no_match(/My draft post in progress/, response.body)
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

  test "inline publish redirects to cohort on success" do
    sign_in users(:attendee)
    draft = posts(:attendee_draft)
    patch cohort_post_path(cohorts(:kabul_retreat), draft), params: {
      publish: "1",
      inline_feed: "1",
      post: { body: "Content" }
    }
    assert_redirected_to cohort_path(cohorts(:kabul_retreat), tab: :feed)
    draft.reload
    assert_not draft.draft?
  end

  test "inline publish renders cohort show on validation failure" do
    sign_in users(:attendee)
    draft = posts(:attendee_draft)
    patch cohort_post_path(cohorts(:kabul_retreat), draft), params: {
      publish: "1",
      inline_feed: "1",
      post: { body: "" }
    }
    assert_response :unprocessable_entity
    assert_select "[data-controller='inline-post-form']"
    draft.reload
    assert draft.draft?
  end
end
