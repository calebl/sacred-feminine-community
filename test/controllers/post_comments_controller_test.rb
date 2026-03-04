require "test_helper"

class PostCommentsControllerTest < ActionDispatch::IntegrationTest
  test "member can add comment" do
    sign_in users(:attendee)
    assert_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
        post_comment: { body: "Great post!" }
      }
    end
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
  end

  test "member can add comment via turbo_stream" do
    sign_in users(:attendee)
    assert_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)),
        params: { post_comment: { body: "Great post!" } },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "admin can add comment even when not a member" do
    sign_in users(:admin)
    assert_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
        post_comment: { body: "Admin comment" }
      }
    end
  end

  test "non-member cannot add comment" do
    sign_in users(:attendee_two)
    assert_no_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
        post_comment: { body: "Sneaky comment" }
      }
    end
    assert_redirected_to root_path
  end

  test "blank comment redirects with alert" do
    sign_in users(:attendee)
    assert_no_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
        post_comment: { body: "" }
      }
    end
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
    assert_equal "Comment could not be saved.", flash[:alert]
  end

  test "author can delete own comment" do
    sign_in users(:attendee)
    comment = post_comments(:attendee_comment)
    assert_difference "PostComment.count", -1 do
      delete cohort_post_post_comment_path(cohorts(:kabul_retreat), posts(:pinned_announcement), comment)
    end
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), posts(:pinned_announcement))
  end

  test "admin can delete any comment" do
    sign_in users(:admin)
    comment = post_comments(:attendee_comment)
    assert_difference "PostComment.count", -1 do
      delete cohort_post_post_comment_path(cohorts(:kabul_retreat), posts(:pinned_announcement), comment)
    end
  end

  test "unauthenticated user cannot comment" do
    assert_no_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
        post_comment: { body: "Not logged in" }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "member can reply to a comment" do
    sign_in users(:attendee)
    parent = post_comments(:admin_comment)
    assert_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)), params: {
        post_comment: { body: "Great reply!", parent_id: parent.id }
      }
    end
    reply = PostComment.last
    assert_equal parent, reply.parent
    assert_redirected_to cohort_post_path(cohorts(:kabul_retreat), posts(:attendee_post))
  end

  test "reply via turbo_stream targets parent replies container" do
    sign_in users(:attendee)
    parent = post_comments(:admin_comment)
    assert_difference "PostComment.count" do
      post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)),
        params: { post_comment: { body: "Turbo reply!", parent_id: parent.id } },
        as: :turbo_stream
    end
    assert_response :success
    assert_includes response.body, "replies_for_#{parent.id}"
  end

  test "reply via turbo_stream updates reply count" do
    sign_in users(:attendee)
    parent = post_comments(:admin_comment)
    post cohort_post_post_comments_path(cohorts(:kabul_retreat), posts(:attendee_post)),
      params: { post_comment: { body: "Another reply!", parent_id: parent.id } },
      as: :turbo_stream
    assert_includes response.body, "reply_count_for_#{parent.id}"
    assert_includes response.body, "#{parent.replies.count} replies"
  end

  test "deleting comment with replies cascades" do
    sign_in users(:admin)
    parent = post_comments(:admin_comment)
    assert_difference "PostComment.count", -3 do
      delete cohort_post_post_comment_path(cohorts(:kabul_retreat), posts(:attendee_post), parent)
    end
  end
end
