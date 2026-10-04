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

  test "clears audit rows about and by the user, including membership audits" do
    @user.update!(bio: "A new bio")
    membership = cohort_memberships.attendee_in_kabul
    Audited.audit_class.create!(auditable: membership, action: "update", audited_changes: {})
    Audited.audit_class.create!(auditable: cohorts.kabul_retreat, user: @user, action: "update", audited_changes: {})

    @user.destroy_account!

    audits = Audited.audit_class
    assert_not audits.exists?(auditable_type: "User", auditable_id: @user.id)
    assert_not audits.exists?(user_type: "User", user_id: @user.id)
    assert_not audits.exists?(auditable_type: "CohortMembership", auditable_id: membership.id)
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
end
