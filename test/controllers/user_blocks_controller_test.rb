require "test_helper"

class UserBlocksControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is redirected" do
    get user_blocks_path
    assert_redirected_to new_user_session_path
  end

  test "authenticated user can view blocked users list" do
    sign_in users(:attendee)
    get user_blocks_path
    assert_response :success
    assert_match users(:attendee_two).name, response.body
  end

  test "empty state shown when no blocked users" do
    sign_in users(:admin)
    get user_blocks_path
    assert_response :success
    assert_match "You haven't blocked anyone", response.body
  end

  test "user can block another user" do
    sign_in users(:admin)
    assert_difference "UserBlock.count", 1 do
      post user_blocks_path, params: { blocked_id: users(:attendee).id }
    end
    assert_redirected_to profile_path(users(:attendee))
    assert_match "has been blocked", flash[:notice]
  end

  test "user cannot block themselves" do
    sign_in users(:admin)
    assert_no_difference "UserBlock.count" do
      post user_blocks_path, params: { blocked_id: users(:admin).id }
    end
    assert flash[:alert].present?
  end

  test "user can unblock a blocked user" do
    sign_in users(:attendee)
    block = user_blocks(:attendee_blocks_attendee_two)
    assert_difference "UserBlock.count", -1 do
      delete user_block_path(block)
    end
    assert_match "has been unblocked", flash[:notice]
  end

  test "user cannot unblock a block they did not create" do
    sign_in users(:admin)
    block = user_blocks(:attendee_blocks_attendee_two)
    assert_no_difference "UserBlock.count" do
      delete user_block_path(block)
    end
    assert_response :not_found
  end
end
