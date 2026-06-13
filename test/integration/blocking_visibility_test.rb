require "test_helper"

# Guard rail for the blocking feature: every surface that lists user-authored
# content (posts and comments) must hide content when a block exists between
# the viewer and the author. If a new content feed is added without applying
# the `visible_to` scope (directly or via a policy scope), the matching test
# here should fail. Add a case below whenever a new content-listing surface
# ships.
class BlockingVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    # admin is a member of kabul_retreat and book_club (see fixtures), so it can
    # view those cohort/group feeds. admin blocks attendee, who has authored
    # content on every surface below.
    @viewer = users(:admin)
    @blocked = users(:attendee)
    @viewer.user_blocks.create!(blocked: @blocked)
    sign_in @viewer
  end

  # Content authored by the blocked user that must NOT appear, paired with
  # content from an unblocked author that MUST still appear, per surface.
  {
    "dashboard feed" => {
      path: :authenticated_root_path,
      hidden: "Hello everyone, excited to be here!", # attendee feed post
      shown: "A post visible to all community members." # admin feed post
    },
    "community feed index" => {
      path: :feed_posts_path,
      hidden: "Hello everyone, excited to be here!",
      shown: "A post visible to all community members."
    }
  }.each do |surface, expected|
    test "#{surface} hides content authored by a blocked user" do
      get public_send(expected[:path])
      assert_response :success
      assert_no_match expected[:hidden], response.body, "#{surface} should hide the blocked author's content"
      assert_match expected[:shown], response.body, "#{surface} should still show other authors' content"
    end
  end

  test "cohort feed hides posts authored by a blocked user" do
    get cohort_path(cohorts(:kabul_retreat))
    assert_response :success
    assert_no_match "This is my first post in the cohort.", response.body # attendee's cohort post
    assert_match "Welcome to our retreat! We are excited to have you.", response.body # admin's cohort post
  end

  test "group feed hides posts authored by a blocked user" do
    get group_path(groups(:book_club))
    assert_response :success
    assert_no_match "Welcome to our book club! Share your favorite reads.", response.body # attendee's group post
    assert_match "Just finished an amazing novel.", response.body # admin's group post
  end

  test "post comments hide comments authored by a blocked user" do
    # pinned_announcement is admin's own post; attendee commented on it.
    get cohort_post_path(cohorts(:kabul_retreat), posts(:pinned_announcement))
    assert_response :success
    assert_no_match "Thank you for the welcome!", response.body # attendee's comment
  end
end
