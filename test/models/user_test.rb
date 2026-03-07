require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "requires name" do
    user = User.new(email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "requires email" do
    user = User.new(name: "Test", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "role defaults to attendee" do
    user = User.new
    assert_equal "attendee", user.role
  end

  test "admin? returns true for admin role" do
    assert users(:admin).admin?
  end

  test "admin? returns false for attendee role" do
    assert_not users(:attendee).admin?
  end

  test "attendee? returns true for attendee role" do
    assert users(:attendee).attendee?
  end

  test "full_location combines city, state, and country" do
    user = users(:admin)
    assert_equal "Los Angeles, California, United States", user.full_location
  end

  test "full_location handles nil city" do
    user = User.new(country: "France")
    assert_equal "France", user.full_location
  end

  test "full_location handles nil country" do
    user = User.new(city: "Paris")
    assert_equal "Paris", user.full_location
  end

  test "full_location handles both nil" do
    user = User.new
    assert_equal "", user.full_location
  end

  test "show_on_map defaults to false" do
    user = User.new
    assert_equal false, user.show_on_map
  end

  test "enqueues geocode job when city changes" do
    user = users(:attendee)
    assert_enqueued_with(job: GeocodeUserJob) do
      user.update!(city: "Berlin")
    end
  end

  test "enqueues geocode job when country changes" do
    user = users(:attendee)
    assert_enqueued_with(job: GeocodeUserJob) do
      user.update!(country: "Germany")
    end
  end

  test "enqueues geocode job when state changes" do
    user = users(:attendee)
    assert_enqueued_with(job: GeocodeUserJob) do
      user.update!(state: "Ile-de-France")
    end
  end

  test "rejects invalid avatar content type" do
    user = users(:attendee)
    user.avatar.attach(io: StringIO.new("fake"), filename: "test.txt", content_type: "text/plain")
    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be a JPEG, PNG, GIF, or WebP"
  end

  test "rejects avatar over 5MB" do
    user = users(:attendee)
    user.avatar.attach(io: StringIO.new("x" * 6.megabytes), filename: "big.png", content_type: "image/png")
    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be less than 5MB"
  end

  test "discarded user is not active for authentication" do
    user = users(:attendee)
    user.discard
    assert_not user.active_for_authentication?
  end

  test "kept user is active for authentication" do
    user = users(:attendee)
    assert user.active_for_authentication?
  end

  test "inactive message returns account_removed for discarded user" do
    user = users(:attendee)
    user.discard
    assert_equal :account_removed, user.inactive_message
  end

  test "inactive message returns default for kept user" do
    user = users(:attendee)
    assert_not_equal :account_removed, user.inactive_message
  end

  test "dm_privacy defaults to cohort_members" do
    user = User.new
    assert_equal "cohort_members", user.dm_privacy
  end

  test "accepts_direct_messages_from? returns true when privacy is everyone" do
    recipient = users(:attendee)
    sender = users(:attendee_two)
    recipient.update_column(:dm_privacy, 2) # everyone
    assert recipient.accepts_direct_messages_from?(sender)
  end

  test "accepts_direct_messages_from? returns false when privacy is nobody" do
    recipient = users(:attendee)
    sender = users(:attendee_two)
    recipient.update_column(:dm_privacy, 0) # nobody
    assert_not recipient.accepts_direct_messages_from?(sender)
  end

  test "accepts_direct_messages_from? returns true for cohort member when privacy is cohort_members" do
    recipient = users(:attendee)
    sender = users(:attendee_two)
    recipient.update_column(:dm_privacy, 1) # cohort_members
    # put both in the same cohort
    CohortMembership.find_or_create_by!(cohort: cohorts(:kabul_retreat), user: sender)
    assert recipient.accepts_direct_messages_from?(sender)
  end

  test "accepts_direct_messages_from? returns false for non-cohort member when privacy is cohort_members" do
    recipient = users(:attendee)
    sender = users(:attendee_two)
    recipient.update_column(:dm_privacy, 1) # cohort_members
    # attendee_two is not in any shared cohort with attendee
    assert_not recipient.accepts_direct_messages_from?(sender)
  end

  test "accepts_direct_messages_from? returns true when sender is admin regardless of privacy" do
    recipient = users(:attendee)
    sender = users(:admin)
    recipient.update_column(:dm_privacy, 0) # nobody
    assert recipient.accepts_direct_messages_from?(sender)
  end

  test "accepts_direct_messages_from? returns false when recipient is admin with privacy nobody" do
    recipient = users(:admin)
    sender = users(:attendee_two)
    recipient.update_column(:dm_privacy, 0) # nobody
    assert_not recipient.accepts_direct_messages_from?(sender)
  end

  test "accepts_direct_messages_from? returns true when recipient is admin with privacy everyone" do
    recipient = users(:admin)
    sender = users(:attendee_two)
    recipient.update_column(:dm_privacy, 2) # everyone
    assert recipient.accepts_direct_messages_from?(sender)
  end

  test "mention_privacy defaults to everywhere" do
    user = User.new
    assert_equal "everywhere", user.mention_privacy
  end

  test "accepts_mentions_in? returns true for all contexts when everywhere" do
    user = users(:attendee)
    user.update_column(:mention_privacy, 2)
    assert user.accepts_mentions_in?(:group)
    assert user.accepts_mentions_in?(:cohort)
    assert user.accepts_mentions_in?(:feed)
    assert user.accepts_mentions_in?(:dm)
  end

  test "accepts_mentions_in? returns true for group and cohort when groups_and_cohorts" do
    user = users(:attendee)
    user.update_column(:mention_privacy, 1)
    assert user.accepts_mentions_in?(:group)
    assert user.accepts_mentions_in?(:cohort)
    assert_not user.accepts_mentions_in?(:feed)
    assert_not user.accepts_mentions_in?(:dm)
  end

  test "accepts_mentions_in? returns false for all contexts when nobody" do
    user = users(:attendee)
    user.update_column(:mention_privacy, 0)
    assert_not user.accepts_mentions_in?(:group)
    assert_not user.accepts_mentions_in?(:cohort)
    assert_not user.accepts_mentions_in?(:feed)
    assert_not user.accepts_mentions_in?(:dm)
  end

  test "accepts_mentions_in? returns false for nil context" do
    user = users(:attendee)
    user.update_column(:mention_privacy, 2)
    assert_not user.accepts_mentions_in?(nil)
  end

  test "notify_admins_of_acceptance enqueues push notifications for admins on invitation acceptance" do
    user = User.invite!({ email: "notify-test@example.com", name: "Notify Test" }, users(:admin))
    admin_count = User.admin.where.not(id: user.id).count

    assert_enqueued_jobs admin_count, only: SendPushNotificationJob do
      user.accept_invitation!
    end
  end

  test "create_invited_cohort_memberships creates memberships for stored cohort ids" do
    kabul = cohorts(:kabul_retreat)
    bali = cohorts(:bali_retreat)

    user = User.invite!({ email: "model-test@example.com", name: "Model Test", invited_cohort_ids: [ kabul.id, bali.id ] }, users(:admin))
    assert_equal [ kabul.id, bali.id ].sort, user.invited_cohort_ids.map(&:to_i).sort

    user.accept_invitation!
    user.reload

    assert_includes user.cohorts, kabul
    assert_includes user.cohorts, bali
    assert_empty user.invited_cohort_ids
  end

  test "create_invited_cohort_memberships ignores discarded cohorts" do
    kabul = cohorts(:kabul_retreat)
    kabul.discard

    user = User.invite!({ email: "discard-test@example.com", name: "Discard Test", invited_cohort_ids: [ kabul.id ] }, users(:admin))
    user.accept_invitation!
    user.reload

    assert_not_includes user.cohorts, kabul
  end

  test "create_invited_cohort_memberships does nothing when no cohort ids" do
    user = User.invite!({ email: "no-cohorts@example.com", name: "No Cohorts" }, users(:admin))

    assert_no_difference "CohortMembership.count" do
      user.accept_invitation!
    end
  end

  test "avatar has a display variant" do
    user = users(:attendee)
    user.avatar.attach(
      io: file_fixture("avatar.png").open,
      filename: "avatar.png",
      content_type: "image/png"
    )
    assert user.avatar.attached?
    variant = user.avatar.variant(:display)
    assert_not_nil variant
  end
end
