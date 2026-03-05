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

  test "invalid inline post renders group show" do
    sign_in users(:attendee)
    assert_no_difference "GroupPost.count" do
      post group_group_posts_path(groups(:book_club)), params: {
        inline_feed: "1",
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
end
