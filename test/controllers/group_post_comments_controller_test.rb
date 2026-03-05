require "test_helper"

class GroupPostCommentsControllerTest < ActionDispatch::IntegrationTest
  test "member can add comment" do
    sign_in users(:attendee)
    assert_difference "GroupPostComment.count" do
      post group_group_post_group_post_comments_path(groups(:book_club), group_posts(:book_club_post)), params: {
        group_post_comment: { body: "Great post!" }
      }
    end
    assert_redirected_to group_group_post_path(groups(:book_club), group_posts(:book_club_post))
  end

  test "member can add comment via turbo_stream" do
    sign_in users(:attendee)
    assert_difference "GroupPostComment.count" do
      post group_group_post_group_post_comments_path(groups(:book_club), group_posts(:book_club_post)),
        params: { group_post_comment: { body: "Great post!" } },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "non-member cannot add comment" do
    sign_in users(:attendee_two)
    assert_no_difference "GroupPostComment.count" do
      post group_group_post_group_post_comments_path(groups(:book_club), group_posts(:book_club_post)), params: {
        group_post_comment: { body: "Sneaky comment" }
      }
    end
    assert_redirected_to root_path
  end

  test "blank comment redirects with alert" do
    sign_in users(:attendee)
    assert_no_difference "GroupPostComment.count" do
      post group_group_post_group_post_comments_path(groups(:book_club), group_posts(:book_club_post)), params: {
        group_post_comment: { body: "" }
      }
    end
    assert_redirected_to group_group_post_path(groups(:book_club), group_posts(:book_club_post))
    assert_equal "Comment could not be saved.", flash[:alert]
  end

  test "author can delete own comment" do
    sign_in users(:attendee)
    comment = group_post_comments(:attendee_group_comment)
    assert_difference "GroupPostComment.count", -1 do
      delete group_group_post_group_post_comment_path(groups(:book_club), group_posts(:book_club_pinned), comment)
    end
    assert_redirected_to group_group_post_path(groups(:book_club), group_posts(:book_club_pinned))
  end

  test "admin can delete any comment" do
    sign_in users(:admin)
    comment = group_post_comments(:attendee_group_comment)
    assert_difference "GroupPostComment.count", -1 do
      delete group_group_post_group_post_comment_path(groups(:book_club), group_posts(:book_club_pinned), comment)
    end
  end

  test "unauthenticated user cannot comment" do
    assert_no_difference "GroupPostComment.count" do
      post group_group_post_group_post_comments_path(groups(:book_club), group_posts(:book_club_post)), params: {
        group_post_comment: { body: "Not logged in" }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "member can reply to a comment" do
    sign_in users(:attendee)
    parent = group_post_comments(:admin_group_comment)
    assert_difference "GroupPostComment.count" do
      post group_group_post_group_post_comments_path(groups(:book_club), group_posts(:book_club_post)), params: {
        group_post_comment: { body: "Great reply!", parent_id: parent.id }
      }
    end
    reply = GroupPostComment.last
    assert_equal parent, reply.parent
    assert_redirected_to group_group_post_path(groups(:book_club), group_posts(:book_club_post))
  end

  test "reply via turbo_stream targets parent replies container" do
    sign_in users(:attendee)
    parent = group_post_comments(:admin_group_comment)
    assert_difference "GroupPostComment.count" do
      post group_group_post_group_post_comments_path(groups(:book_club), group_posts(:book_club_post)),
        params: { group_post_comment: { body: "Turbo reply!", parent_id: parent.id } },
        as: :turbo_stream
    end
    assert_response :success
    assert_includes response.body, "replies_for_#{parent.id}"
  end

  test "deleting comment with replies cascades" do
    sign_in users(:admin)
    parent = group_post_comments(:admin_group_comment)
    assert_difference "GroupPostComment.count", -3 do
      delete group_group_post_group_post_comment_path(groups(:book_club), group_posts(:book_club_post), parent)
    end
  end
end
