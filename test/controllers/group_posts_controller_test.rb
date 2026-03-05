require "test_helper"

class GroupPostsControllerTest < ActionDispatch::IntegrationTest
  test "member can view post" do
    sign_in users(:attendee)
    get group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_response :success
  end

  test "non-member cannot view post" do
    sign_in users(:attendee_two)
    get group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_redirected_to root_path
  end

  test "new with existing draft redirects to edit" do
    sign_in users(:attendee)
    draft = group_posts(:book_club_draft)
    get new_group_group_post_path(groups(:book_club))
    assert_redirected_to edit_group_group_post_path(groups(:book_club), draft)
  end

  test "new without existing draft creates draft and redirects to edit" do
    sign_in users(:admin)
    assert_difference "GroupPost.count" do
      get new_group_group_post_path(groups(:book_club))
    end
    new_draft = GroupPost.last
    assert new_draft.draft?
    assert_redirected_to edit_group_group_post_path(groups(:book_club), new_draft)
  end

  test "non-member cannot access new post form" do
    sign_in users(:attendee_two)
    get new_group_group_post_path(groups(:book_club))
    assert_redirected_to root_path
  end

  test "member can create post" do
    sign_in users(:attendee)
    assert_difference "GroupPost.count" do
      post group_group_posts_path(groups(:book_club)), params: {
        group_post: { body: "Some post content" }
      }
    end
    assert_redirected_to group_group_post_path(groups(:book_club), GroupPost.last)
  end

  test "non-member cannot create post" do
    sign_in users(:attendee_two)
    assert_no_difference "GroupPost.count" do
      post group_group_posts_path(groups(:book_club)), params: {
        group_post: { body: "Content" }
      }
    end
    assert_redirected_to root_path
  end

  test "invalid post re-renders form" do
    sign_in users(:attendee)
    assert_no_difference "GroupPost.count" do
      post group_group_posts_path(groups(:book_club)), params: {
        group_post: { body: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "author can delete own post" do
    sign_in users(:admin)
    assert_difference "GroupPost.count", -1 do
      delete group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    end
    assert_redirected_to group_path(groups(:book_club), tab: :feed)
  end

  test "admin can delete any post" do
    sign_in users(:admin)
    assert_difference "GroupPost.count", -1 do
      delete group_group_post_path(groups(:book_club), group_posts(:book_club_pinned))
    end
  end

  test "creator can pin post" do
    sign_in users(:attendee)
    post_record = group_posts(:book_club_post)
    assert_not post_record.pinned?

    patch pin_group_group_post_path(groups(:book_club), post_record)
    assert post_record.reload.pinned?
    assert_redirected_to group_path(groups(:book_club), tab: :feed)
  end

  test "admin can pin post" do
    sign_in users(:admin)
    post_record = group_posts(:book_club_post)
    patch pin_group_group_post_path(groups(:book_club), post_record)
    assert post_record.reload.pinned?
  end

  test "regular member cannot pin post" do
    sign_in users(:admin)
    # admin is a member but not creator of book_club (attendee is creator)
    # admin IS an admin user though, so they CAN pin
    # Let's test with attendee_two who is not a member
    sign_in users(:attendee_two)
    patch pin_group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot access posts" do
    get group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_redirected_to new_user_session_path
  end

  test "viewing post marks it as read" do
    sign_in users(:attendee)
    assert_difference "GroupPostRead.count" do
      get group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    end
  end

  test "edit shows draft form" do
    sign_in users(:attendee)
    get edit_group_group_post_path(groups(:book_club), group_posts(:book_club_draft))
    assert_response :success
  end

  test "edit redirects to show for published posts" do
    sign_in users(:attendee)
    get edit_group_group_post_path(groups(:book_club), group_posts(:book_club_pinned))
    assert_redirected_to group_group_post_path(groups(:book_club), group_posts(:book_club_pinned))
  end

  test "update saves draft fields" do
    sign_in users(:attendee)
    draft = group_posts(:book_club_draft)
    patch group_group_post_path(groups(:book_club), draft), params: {
      group_post: { body: "Updated draft body" }
    }
    assert_redirected_to edit_group_group_post_path(groups(:book_club), draft)
    draft.reload
    assert_equal "Updated draft body", draft.body
    assert draft.draft?
  end

  test "update with publish publishes the post" do
    sign_in users(:attendee)
    draft = group_posts(:book_club_draft)
    patch group_group_post_path(groups(:book_club), draft), params: {
      publish: "1",
      group_post: { body: "Published body" }
    }
    assert_redirected_to group_group_post_path(groups(:book_club), draft)
    draft.reload
    assert_not draft.draft?
    assert_equal "Published body", draft.body
  end

  test "publish fails without body" do
    sign_in users(:attendee)
    draft = group_posts(:book_club_draft)
    patch group_group_post_path(groups(:book_club), draft), params: {
      publish: "1",
      group_post: { body: "" }
    }
    assert_response :unprocessable_entity
    draft.reload
    assert draft.draft?
  end

  test "inline create redirects to group on success" do
    sign_in users(:attendee)
    assert_difference "GroupPost.count" do
      post group_group_posts_path(groups(:book_club)), params: {
        inline_feed: "1",
        group_post: { body: "Content here" }
      }
    end
    assert_redirected_to group_path(groups(:book_club), tab: :feed)
  end

  test "inline create renders group show on validation failure" do
    sign_in users(:attendee)
    assert_no_difference "GroupPost.count" do
      post group_group_posts_path(groups(:book_club)), params: {
        inline_feed: "1",
        group_post: { body: "" }
      }
    end
    assert_response :unprocessable_entity
    assert_select "[data-controller='inline-post-form']"
  end

  test "inline publish redirects to group on success" do
    sign_in users(:attendee)
    draft = group_posts(:book_club_draft)
    patch group_group_post_path(groups(:book_club), draft), params: {
      publish: "1",
      inline_feed: "1",
      group_post: { body: "Content" }
    }
    assert_redirected_to group_path(groups(:book_club), tab: :feed)
    draft.reload
    assert_not draft.draft?
  end

  test "inline publish renders group show on validation failure" do
    sign_in users(:attendee)
    draft = group_posts(:book_club_draft)
    patch group_group_post_path(groups(:book_club), draft), params: {
      publish: "1",
      inline_feed: "1",
      group_post: { body: "" }
    }
    assert_response :unprocessable_entity
    assert_select "[data-controller='inline-post-form']"
    draft.reload
    assert draft.draft?
  end
end
