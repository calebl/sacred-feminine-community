require "test_helper"

# Guard rail for cohort gender content filtering, mirroring
# BlockingVisibilityTest: every surface that lists user-authored content must
# hide content from the side of the community the viewer excluded, and must keep
# showing admin-authored content (admins are exempt from this filter). If a new
# content feed ships without going through `visible_to` / `policy_scope`, the
# matching test here should fail. Add a case below whenever a new
# content-listing surface ships.
class CohortGenderVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    # women_only_member is in kabul_retreat and book_club, so she can view those
    # feeds. male_member belongs to a men's cohort and has authored content on
    # every surface below.
    @viewer = users.women_only_member
    @male_member = users.male_member
    sign_in @viewer
  end

  # Content authored by the excluded male cohort member that must NOT appear,
  # paired with admin content that MUST still appear, per surface.
  {
    "dashboard feed" => {
      path: :authenticated_root_path,
      hidden: "A feed post from a male cohort member.",
      shown: "A post visible to all community members." # admin feed post
    },
    "community feed index" => {
      path: :feed_posts_path,
      hidden: "A feed post from a male cohort member.",
      shown: "A post visible to all community members."
    }
  }.each do |surface, expected|
    test "#{surface} hides content from an excluded cohort gender" do
      get public_send(expected[:path])
      assert_response :success
      assert_no_match expected[:hidden], response.body, "#{surface} should hide the excluded member's content"
      assert_match expected[:shown], response.body, "#{surface} should still show admin content"
    end
  end

  test "cohort feed hides posts from an excluded cohort gender" do
    get cohort_path(cohorts.kabul_retreat)
    assert_response :success
    assert_no_match "A cohort post from a male cohort member.", response.body
    assert_match "Welcome to our retreat! We are excited to have you.", response.body # admin's cohort post
  end

  test "group feed hides posts from an excluded cohort gender" do
    get group_path(groups.book_club)
    assert_response :success
    assert_no_match "A group post from a male cohort member.", response.body
    assert_match "Just finished an amazing novel.", response.body # admin's group post
  end

  test "post comments hide comments from an excluded cohort gender" do
    get cohort_post_path(cohorts.kabul_retreat, posts.pinned_announcement)
    assert_response :success
    assert_no_match "A comment from a male cohort member.", response.body
  end

  test "cohort feed card comments hide comments from an excluded cohort gender" do
    get cohort_path(cohorts.kabul_retreat)
    assert_response :success
    assert_no_match "A comment from a male cohort member.", response.body
  end

  test "dashboard member list omits an excluded cohort gender" do
    get authenticated_root_path(tab: "members")
    assert_response :success
    assert_no_match @male_member.name, response.body
    assert_match users.admin.name, response.body
  end

  test "cohort member list omits an excluded cohort gender" do
    get cohort_path(cohorts.kabul_retreat, tab: "members")
    assert_response :success
    assert_no_match @male_member.name, response.body
  end

  test "map pins omit an excluded cohort gender" do
    @male_member.update!(show_on_map: true, latitude: 39.7392, longitude: -104.9903)
    users.admin.update!(latitude: 34.0522, longitude: -118.2437)

    get api_map_pins_path(format: :json)
    assert_response :success
    names = JSON.parse(response.body).map { |pin| pin["name"] }
    assert_not_includes names, @male_member.name
    assert_includes names, users.admin.name
  end

  test "a rendered mention of an excluded member is plain text, not a profile link" do
    FeedPost.create!(user: users.admin,
                     body: "Welcome @[#{@male_member.name}](#{@male_member.id}) and @[#{users.admin_two.name}](#{users.admin_two.id})")

    get feed_posts_path
    assert_response :success
    assert_match "@#{@male_member.name}", response.body
    assert_no_match %r{/profiles/#{@male_member.id}"[^>]*>@#{@male_member.name}}, response.body
    assert_match %r{/profiles/#{users.admin_two.id}"[^>]*>@#{users.admin_two.name}}, response.body
  end

  test "mention autocomplete omits an excluded cohort gender but keeps admins" do
    get mention_searches_path(q: "M", cohort_id: cohorts.kabul_retreat.id), xhr: true
    assert_response :success
    assert_no_match @male_member.name, response.body
  end

  test "the filter is mutual: the excluded member cannot see the viewer's content" do
    viewer_post = FeedPost.create!(user: @viewer, body: "A feed post from a female cohort member.")

    sign_out @viewer
    sign_in @male_member

    get feed_posts_path
    assert_response :success
    assert_no_match viewer_post.body, response.body
    assert_match "A post visible to all community members.", response.body
  end

  test "admin content stays visible to a men_only viewer" do
    sign_out @viewer
    sign_in users.men_only_member

    get feed_posts_path
    assert_response :success
    assert_match "A post visible to all community members.", response.body # admin feed post
    assert_no_match "Hello everyone, excited to be here!", response.body # female attendee's post
  end

  test "direct messages are blocked across the gender boundary but not from admins" do
    @male_member.update!(dm_privacy: :everyone)
    users.admin.update!(dm_privacy: :everyone)

    assert_no_difference "Conversation.count" do
      post conversations_path, params: { recipient_id: @male_member.id, body: "Hello" }
    end
    assert_match "not accepting direct messages", flash[:alert]

    assert_difference "Conversation.count", 1 do
      post conversations_path, params: { recipient_id: users.admin.id, body: "Hello" }
    end
  end

  test "DM recipient search omits an excluded cohort gender" do
    get conversations_member_searches_path(q: "Member"), xhr: true
    assert_response :success
    assert_no_match @male_member.name, response.body
  end
end
