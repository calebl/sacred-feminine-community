require "test_helper"

class FeedPosts::PinsControllerTest < ActionDispatch::IntegrationTest
  test "admin can pin a feed post" do
    sign_in users(:admin)
    post_record = feed_posts(:public_post)
    assert_not post_record.pinned?

    patch feed_post_pin_path(post_record)
    assert post_record.reload.pinned?
    assert_redirected_to feed_posts_path
  end

  test "admin can unpin a feed post" do
    sign_in users(:admin)
    post_record = feed_posts(:pinned_feed_post)
    assert post_record.pinned?

    patch feed_post_pin_path(post_record)
    assert_not post_record.reload.pinned?
    assert_redirected_to feed_posts_path
  end

  test "non-admin cannot pin" do
    sign_in users(:attendee)
    patch feed_post_pin_path(feed_posts(:public_post))
    assert_redirected_to root_path
  end
end
