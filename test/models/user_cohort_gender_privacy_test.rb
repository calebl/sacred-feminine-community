require "test_helper"

# Cohort gender filtering: a non-admin in a men's cohort is a male cohort member,
# everyone else (including admins and users with no cohort) is a female cohort
# member. The preference hides content mutually, exactly like blocking, and never
# hides admin-authored content.
class UserCohortGenderPrivacyTest < ActiveSupport::TestCase
  test "defaults to allowing content from all members" do
    assert User.new.cohort_gender_privacy_all_members?
  end

  test "male_cohort_member? is true for an attendee in a men's cohort" do
    assert users.male_member.male_cohort_member?
    assert_not users.male_member.female_cohort_member?
  end

  test "male_cohort_member? is false for a women's cohort attendee" do
    assert_not users.attendee.male_cohort_member?
    assert users.attendee.female_cohort_member?
  end

  test "male_cohort_member? is false for a user with no cohort" do
    loner = User.create!(name: "Loner", email: "loner@example.com", password: "password123")

    assert_not loner.male_cohort_member?
    assert loner.female_cohort_member?
  end

  test "male_cohort_member? is false for an admin in a men's cohort" do
    admin = users.admin
    CohortMembership.create!(user: admin, cohort: cohorts.mens_gathering)

    assert_not admin.reload.male_cohort_member?
  end

  test "male_cohort_member? ignores memberships in discarded men's cohorts" do
    male = users.male_member
    cohorts.mens_gathering.discard!

    assert_not male.reload.male_cohort_member?
  end

  test "male_cohort_members and female_cohort_members partition all users" do
    male_ids = User.male_cohort_members.pluck(:id)
    female_ids = User.female_cohort_members.pluck(:id)

    assert_includes male_ids, users.male_member.id
    assert_includes female_ids, users.attendee.id
    assert_includes female_ids, users.admin.id
    assert_empty male_ids & female_ids
    assert_equal User.count, (male_ids + female_ids).uniq.size
  end

  test "women_only hides male cohort members but never admins" do
    hidden = users.women_only_member.cohort_gender_hidden_user_ids

    assert_includes hidden, users.male_member.id
    assert_not_includes hidden, users.admin.id
    assert_not_includes hidden, users.attendee.id
  end

  test "men_only hides female cohort members but never admins or self" do
    hidden = users.men_only_member.cohort_gender_hidden_user_ids

    assert_includes hidden, users.attendee.id
    assert_not_includes hidden, users.admin.id
    assert_not_includes hidden, users.men_only_member.id
    assert_not_includes hidden, users.male_member.id
  end

  test "a female cohort member cannot exclude female cohort members" do
    female = users.attendee
    female.cohort_gender_privacy = :men_only

    assert_not female.valid?
    assert_includes female.errors[:cohort_gender_privacy], "can't hide female cohort members' content while you are one"
  end

  test "a male cohort member cannot exclude male cohort members" do
    male = users.male_member
    male.cohort_gender_privacy = :women_only

    assert_not male.valid?
    assert_includes male.errors[:cohort_gender_privacy], "can't hide male cohort members' content while you are one"
  end

  test "an admin counts as female and cannot exclude female cohort members" do
    admin = users.admin
    admin.cohort_gender_privacy = :men_only

    assert_not admin.valid?
  end

  test "each side can still exclude the other" do
    assert users.attendee.update(cohort_gender_privacy: :women_only)
    assert users.male_member.update(cohort_gender_privacy: :men_only)
  end

  test "a membership change that strands a setting falls back to all_members" do
    female = users.attendee
    female.update!(cohort_gender_privacy: :women_only)

    # Joining a men's cohort reclassifies her; women_only would now exclude her
    # own side, so it stops taking effect rather than hiding everyone.
    CohortMembership.create!(user: female, cohort: cohorts.mens_gathering)
    female = User.find(female.id)

    assert_predicate female, :male_cohort_member?
    assert_predicate female, :cohort_gender_privacy_women_only?
    assert_equal "all_members", female.effective_cohort_gender_privacy
    assert_not_includes female.cohort_gender_hidden_user_ids, users.male_member.id
  end

  test "a stranded setting does not hide its owner from the other side either" do
    female = users.attendee
    female.update!(cohort_gender_privacy: :women_only)
    CohortMembership.create!(user: female, cohort: cohorts.mens_gathering)

    assert_not_includes User.find(users.male_member.id).cohort_gender_hidden_user_ids, female.id
  end

  test "a stranded setting does not block unrelated profile updates" do
    female = users.attendee
    female.update!(cohort_gender_privacy: :women_only)
    CohortMembership.create!(user: female, cohort: cohorts.mens_gathering)

    assert User.find(female.id).update(bio: "Updated bio")
  end

  test "the filter is mutual even when only one side sets a preference" do
    assert_includes users.women_only_member.hidden_content_user_ids, users.male_member.id
    assert_includes users.male_member.hidden_content_user_ids, users.women_only_member.id
    assert users.male_member.cohort_gender_privacy_all_members?
  end

  test "all_members on both sides hides neither party" do
    assert users.attendee.cohort_gender_privacy_all_members?
    assert users.male_member.cohort_gender_privacy_all_members?

    assert_not_includes users.attendee.cohort_gender_hidden_user_ids, users.male_member.id
    assert_not_includes users.male_member.cohort_gender_hidden_user_ids, users.attendee.id
    assert_not_includes users.attendee.cohort_gender_hidden_user_ids, users.attendee_two.id
  end

  test "no one's preference hides their content from an admin" do
    assert_empty users.admin.cohort_gender_hidden_user_ids
    assert_empty users.admin_two.cohort_gender_hidden_user_ids
  end

  test "an admin's own preference still narrows what they see" do
    # An admin counts as a female cohort member, so women_only is valid for them.
    users.admin.update!(cohort_gender_privacy: :women_only)

    assert_includes users.admin.reload.cohort_gender_hidden_user_ids, users.male_member.id
  end

  test "hidden_content_user_ids still covers blocks" do
    viewer = users.admin
    viewer.user_blocks.create!(blocked: users.attendee)

    assert_includes viewer.reload.hidden_content_user_ids, users.attendee.id
  end

  test "visible_to drops a male member's post for a women_only viewer and keeps the admin's" do
    visible = FeedPost.visible_to(users.women_only_member)

    assert_not_includes visible, feed_posts.male_member_feed_post
    assert_includes visible, feed_posts.public_post
  end

  test "accepts_direct_messages_from? is false across the gender boundary" do
    users.male_member.update!(dm_privacy: :everyone)
    users.women_only_member.update!(dm_privacy: :everyone)

    assert_not users.male_member.reload.accepts_direct_messages_from?(users.women_only_member)
    assert_not users.women_only_member.reload.accepts_direct_messages_from?(users.male_member)
  end

  test "accepts_direct_messages_from? is still true from an admin" do
    users.men_only_member.update!(dm_privacy: :everyone)

    assert users.men_only_member.reload.accepts_direct_messages_from?(users.admin)
  end

  test "hidden_content_user_ids is memoized" do
    viewer = users.women_only_member
    viewer.hidden_content_user_ids

    assert_no_queries do
      viewer.hidden_content_user_ids
    end
  end
end
