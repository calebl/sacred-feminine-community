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

  test "creating a post with mentions creates mention records" do
    sign_in users(:attendee)
    mentioned = users(:admin)
    assert_difference "Mention.count" do
      post group_group_posts_path(groups(:book_club)), params: {
        group_post: { body: "Hello @[#{mentioned.name}](#{mentioned.id})" }
      }
    end
    mention = Mention.last
    assert_equal mentioned, mention.user
    assert_equal users(:attendee), mention.mentioner
    assert_equal "GroupPost", mention.mentionable_type
  end

  test "viewing post marks post-level mentions as read" do
    sign_in users(:admin)
    mentioned_post = group_posts(:book_club_post)
    mention = Mention.create!(
      mentionable: mentioned_post,
      user: users(:admin),
      mentioner: users(:attendee)
    )
    get group_group_post_path(groups(:book_club), mentioned_post)
    assert mention.reload.read_at.present?
  end

  test "author can edit own post" do
    sign_in users(:attendee)
    get edit_group_group_post_path(groups(:book_club), group_posts(:book_club_pinned))
    assert_response :success
  end

  test "non-author member cannot edit post" do
    sign_in users(:attendee)
    get edit_group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_redirected_to root_path
  end

  test "admin can edit any post" do
    sign_in users(:admin)
    get edit_group_group_post_path(groups(:book_club), group_posts(:book_club_pinned))
    assert_response :success
  end

  test "author can update own post" do
    sign_in users(:attendee)
    patch group_group_post_path(groups(:book_club), group_posts(:book_club_pinned)), params: {
      group_post: { body: "Updated post content" }
    }
    assert_redirected_to group_group_post_path(groups(:book_club), group_posts(:book_club_pinned))
    assert_equal "Updated post content", group_posts(:book_club_pinned).reload.body
  end

  test "non-author member cannot update post" do
    sign_in users(:attendee)
    patch group_group_post_path(groups(:book_club), group_posts(:book_club_post)), params: {
      group_post: { body: "Hacked" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked", group_posts(:book_club_post).reload.body
  end

  test "update with blank body re-renders show with errors" do
    sign_in users(:attendee)
    patch group_group_post_path(groups(:book_club), group_posts(:book_club_pinned)), params: {
      group_post: { body: "" }
    }
    assert_response :unprocessable_entity
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

  test "group show renders post-scoped reply containers" do
    sign_in users(:attendee)
    get group_path(groups(:book_club), tab: :feed)
    assert_response :success
    assert_select "#post_comments_for_#{group_posts(:book_club_post).id}"
  end

  test "group show shows reply count with reply text" do
    sign_in users(:attendee)
    get group_path(groups(:book_club), tab: :feed)
    assert_response :success
    assert_select "button", text: /\d+ repl(y|ies)/
  end

  test "group show displays user avatars on posts" do
    sign_in users(:attendee)
    get group_path(groups(:book_club), tab: :feed)
    assert_response :success
    assert_select "div.w-6.h-6.rounded-full", minimum: 1
  end

  test "group post show uses post-scoped reply container" do
    sign_in users(:attendee)
    get group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_response :success
    assert_select "#post_comments_for_#{group_posts(:book_club_post).id}"
  end

  test "group post show uses reply terminology" do
    sign_in users(:attendee)
    get group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_response :success
    assert_select "h2", text: /Replies/
  end

  test "inline edit updates group post via turbo stream" do
    sign_in users(:attendee)
    patch group_group_post_path(groups(:book_club), group_posts(:book_club_pinned)), params: {
      inline_edit: "1",
      group_post: { body: "Inline updated content" }
    }, as: :turbo_stream
    assert_response :success
    assert_equal "Inline updated content", group_posts(:book_club_pinned).reload.body
  end

  test "inline edit with blank body returns unprocessable entity for group post" do
    sign_in users(:attendee)
    original_body = group_posts(:book_club_pinned).body
    patch group_group_post_path(groups(:book_club), group_posts(:book_club_pinned)), params: {
      inline_edit: "1",
      group_post: { body: "" }
    }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_equal original_body, group_posts(:book_club_pinned).reload.body
  end
end
