require "test_helper"

class UserAccountDeletionTest < ActiveSupport::TestCase
  setup do
    @user = users.attendee
  end

  test "hard deletes the user and everything they shared" do
    conversation = conversations.admin_attendee_convo
    message = conversation.direct_messages.create!(sender: @user, body: "Hello there")
    post = posts.attendee_post
    feed_post = feed_posts.attendee_feed_post
    feed_post.photos.attach(io: file_fixture("avatar.png").open, filename: "photo.png", content_type: "image/png")

    @user.destroy_account!

    assert_not User.exists?(@user.id)
    assert_not Post.exists?(post.id)
    assert_not FeedPost.exists?(feed_post.id)
    assert_not DirectMessage.exists?(message.id)
    assert_not PostComment.exists?(user_id: @user.id)
    assert_not HelpRequest.exists?(user_id: @user.id)
    assert_not Reaction.exists?(user_id: @user.id)
    assert_not ActiveStorage::Attachment.exists?(record_type: "FeedPost", record_id: feed_post.id)
    assert Conversation.exists?(conversation.id), "the other participant keeps the conversation"
  end

  test "removes notifications the user caused for others" do
    Notification.create!(user: users.admin, actor: @user, event_type: "mention", title: "Mention")

    @user.destroy_account!

    assert_not Notification.exists?(actor_id: @user.id)
  end

  test "clears audit rows about and by the user, including historical membership audits" do
    @user.update!(bio: "A new bio")
    current_membership = cohort_memberships.attendee_in_kabul
    Audited.audit_class.create!(auditable: current_membership, action: "update", audited_changes: {})
    Audited.audit_class.create!(auditable: cohorts.kabul_retreat, user: @user, action: "update", audited_changes: {})

    historical_memberships = [
      CohortMembership.create!(user: @user, cohort: cohorts.mens_gathering),
      GroupMembership.create!(user: @user, group: groups.reading_group)
    ]
    historical_memberships.each do |membership|
      Audited.audit_class.create!(
        auditable: membership,
        action: "create",
        audited_changes: { "user_id" => [ nil, @user.id ] }
      )
      Audited.audit_class.create!(
        auditable: membership,
        action: "update",
        audited_changes: { "last_read_at" => [ nil, Time.current ] }
      )
      membership.destroy!
    end

    @user.destroy_account!

    audits = Audited.audit_class
    assert_not audits.exists?(auditable_type: "User", auditable_id: @user.id)
    assert_not audits.exists?(user_type: "User", user_id: @user.id)
    assert_not audits.exists?(auditable_type: "CohortMembership", auditable_id: current_membership.id)
    historical_memberships.each do |membership|
      assert_not audits.exists?(auditable_type: membership.class.name, auditable_id: membership.id)
    end
  end

  test "hands groups the user created to an admin" do
    group = groups.book_club

    @user.destroy_account!

    assert_equal users.admin, group.reload.creator
  end

  test "an admin's cohorts and FAQs pass to another admin" do
    admin = users.admin
    cohort = cohorts.kabul_retreat

    admin.destroy_account!

    assert_not User.exists?(admin.id)
    assert_equal users.admin_two, cohort.reload.creator
    assert Faq.where(created_by_id: users.admin_two.id).exists?
  end

  test "retained reports keep reasons but no copy of deleted content" do
    post = posts.attendee_post
    report = ContentReport.new(
      reporter: users.attendee_two,
      reportable: post,
      reason: "Keep this reason"
    ).submit

    @user.destroy_account!

    report.reload
    assert_equal "Report: post", report.subject
    assert_includes report.body, "Keep this reason"
    assert_not_includes report.body, post.body
    assert_nil report.reportable
  end

  test "refuses to delete the only remaining active admin" do
    users.admin_two.update!(role: :attendee)
    users.pending_invite.update!(role: :admin)

    error = assert_raises(ActiveRecord::RecordNotDestroyed) { users.admin.destroy_account! }

    assert_match "Another admin is required", error.message
    assert User.exists?(users.admin.id)
  end

  test "refuses to demote the only remaining active admin" do
    users.admin_two.update!(role: :attendee)

    error = assert_raises(ActiveRecord::RecordInvalid) { users.admin.change_role!(:attendee) }

    assert_includes error.record.errors[:role], "cannot remove the only active admin"
    assert users.admin.reload.admin?
  end
end
