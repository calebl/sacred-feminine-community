require "test_helper"

# The dashboard root renders both the top bar and the sidebar, so every dot
# target is present on one page.
class UnreadIndicatorsRenderingTest < ActionDispatch::IntegrationTest
  include ActionView::RecordIdentifier

  setup do
    @user = users(:attendee)
    sign_in @user
  end

  test "no gold dots when everything is read" do
    get authenticated_root_path
    assert_response :success
    assert_select "#desktop_messages_dot span.bg-sf-gold", false
    cohort = cohorts(:kabul_retreat)
    assert_select "##{dom_id(cohort, :unread_dot)} span.bg-sf-gold", false
  end

  test "messages dot renders for an unread DM notification" do
    Notification.create!(user: @user, event_type: "direct_message", title: "x",
                         notifiable_type: "DirectMessage", notifiable_id: 1)
    get authenticated_root_path
    assert_select "#desktop_messages_dot span.bg-sf-gold"
    assert_select "#mobile_messages_dot span.bg-sf-gold"
  end

  test "cohort dot renders for an unread cohort notification" do
    Notification.create!(user: @user, event_type: "new_post", title: "x",
                         notifiable: posts(:pinned_announcement))
    get authenticated_root_path
    assert_select "##{dom_id(cohorts(:kabul_retreat), :unread_dot)} span.bg-sf-gold"
    assert_select "##{dom_id(cohorts(:bali_retreat), :unread_dot)} span.bg-sf-gold", false
  end

  test "group dot renders for an unread group post notification" do
    Notification.create!(user: @user, event_type: "new_post", title: "x",
                         notifiable: group_posts(:book_club_post))
    get authenticated_root_path
    assert_select "##{dom_id(groups(:book_club), :unread_dot)} span.bg-sf-gold"
  end

  test "group dot does not render for a new_member notification" do
    Notification.create!(user: @user, event_type: "new_member", title: "x",
                         notifiable: groups(:book_club))
    get authenticated_root_path
    assert_select "##{dom_id(groups(:book_club), :unread_dot)} span.bg-sf-gold", false
  end

  test "scroll-into-view observer attaches to an unread post in the cohort feed" do
    post = posts(:attendee_post)
    Notification.create!(user: @user, event_type: "new_post", title: "x", notifiable: post)

    get cohort_path(cohorts(:kabul_retreat))

    assert_select "##{dom_id(post)}[data-controller~='read-on-view']"
    assert_select "##{dom_id(post)}[data-read-on-view-type-value='post']"
  end

  test "no observer attaches to an already-read post" do
    get cohort_path(cohorts(:kabul_retreat))
    assert_select "##{dom_id(posts(:attendee_post))}[data-controller~='read-on-view']", false
  end
end
