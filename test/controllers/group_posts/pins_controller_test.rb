require "test_helper"

class GroupPosts::PinsControllerTest < ActionDispatch::IntegrationTest
  test "creator can pin post" do
    sign_in users(:attendee)
    post_record = group_posts(:book_club_post)
    assert_not post_record.pinned?

    patch group_group_post_pin_path(groups(:book_club), post_record)
    assert post_record.reload.pinned?
    assert_redirected_to group_path(groups(:book_club), tab: :feed)
  end

  test "admin can pin post" do
    sign_in users(:admin)
    post_record = group_posts(:book_club_post)
    patch group_group_post_pin_path(groups(:book_club), post_record)
    assert post_record.reload.pinned?
  end

  test "regular member cannot pin post" do
    sign_in users(:attendee_two)
    patch group_group_post_pin_path(groups(:book_club), group_posts(:book_club_post))
    assert_redirected_to root_path
  end
end
