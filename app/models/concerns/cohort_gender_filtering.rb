# Cohort gender content filtering: a member may choose to see only their own
# side of the community, and that choice hides content mutually — exactly like
# blocking, and through the same choke point (User#hidden_content_user_ids).
#
# Classification comes from the cohort's men's-cohort flag: a non-admin who
# belongs to at least one men's cohort is a male cohort member; everyone else —
# women's-cohort members, users with no cohort at all, and every admin — is a
# female cohort member.
#
# Admins sit outside the filter in both directions: their content always reaches
# everyone, and nobody's preference can hide content from them. That mirrors the
# way admins cannot be blocked (see UserBlock).
#
# The `cohort_gender_privacy` enum itself stays on User, alongside the other
# privacy enums.
module CohortGenderFiltering
  extend ActiveSupport::Concern

  included do
    scope :in_mens_cohort, -> {
      where(id: CohortMembership.joins(:cohort)
                                .where(cohorts: { mens_cohort: true, discarded_at: nil })
                                .select(:user_id))
    }
    # Classification, mirroring #male_cohort_member? / #female_cohort_member?:
    # an admin counts as a female cohort member, so the two scopes partition
    # every user between them.
    scope :male_cohort_members, -> { attendee.in_mens_cohort }
    scope :female_cohort_members, -> { where.not(id: male_cohort_members.select(:id)) }
    # The same two sides, narrowed to the members the filter is allowed to hide.
    # Admins are exempt in both directions, so neither set may contain one:
    # male_cohort_members already excludes them by definition, the female set has
    # to say so explicitly. Hidden-set queries use these, so no caller has to
    # remember the `.attendee` that the asymmetry would otherwise demand.
    scope :filterable_male_members, -> { male_cohort_members }
    scope :filterable_female_members, -> { female_cohort_members.attendee }

    # Only on change: a later cohort membership change can invalidate a setting
    # that was legitimate when chosen, and that must not block unrelated saves.
    validate :cohort_gender_privacy_is_permitted, if: :cohort_gender_privacy_changed?
  end

  # Admins are never classified as male cohort members: their content stays
  # visible to everyone regardless of the cohort gender preference, the same way
  # they cannot be blocked (see UserBlock).
  def male_cohort_member?
    return false if admin?
    return @male_cohort_member if defined?(@male_cohort_member)

    @male_cohort_member = cohorts.exists?(mens_cohort: true)
  end

  def female_cohort_member?
    !male_cohort_member?
  end

  # Admins always see all content, and a member may exclude the other side of the
  # community but never their own. The setting is validated on change, but a
  # later role or cohort membership change can strand an already-valid choice (a
  # woman who joins a men's cohort keeps her women_only setting), so reading it
  # always goes through here.
  def effective_cohort_gender_privacy
    return "all_members" if admin?
    return "all_members" if cohort_gender_privacy_men_only? && female_cohort_member?
    return "all_members" if cohort_gender_privacy_women_only? && male_cohort_member?

    cohort_gender_privacy
  end

  # Ids of users whose content is hidden from this user by the cohort gender
  # preference. Mutual, exactly like blocking: it applies when this user's
  # setting excludes the other's side of the community, OR when the other's
  # setting excludes this user's side. Admins are absent from both candidate
  # sets, so admin-authored content is never hidden.
  #
  # The costliest case is a men_only viewer, where the excluded set is nearly the
  # whole attendee table: one indexed SELECT id, plucked once per request, then
  # carried as bind params on every content query in that request. That is fine
  # for a community of this size and starts to hurt well before SQLite's 32766
  # variable ceiling — revisit it somewhere north of ~2,000 attendees, by
  # splitting Blockable#visible_to into two predicates and keeping this side as a
  # subquery relation instead of an array.
  def cohort_gender_hidden_user_ids
    return @cohort_gender_hidden_user_ids if defined?(@cohort_gender_hidden_user_ids)

    excluded_by_me =
      case effective_cohort_gender_privacy
      when "women_only" then User.filterable_male_members
      when "men_only" then User.filterable_female_members
      else User.none
      end

    # Nobody's preference can hide their content from an admin — admins are
    # outside this filter in both directions, and only their own setting (above)
    # narrows what they see. Each set is restricted to members the setting is
    # valid for, mirroring effective_cohort_gender_privacy from the other side.
    excluding_me =
      if admin?
        User.none
      elsif male_cohort_member?
        User.filterable_female_members.where(cohort_gender_privacy: :women_only)
      else
        User.filterable_male_members.where(cohort_gender_privacy: :men_only)
      end

    # Subtract self, belt and braces: no valid setting can put a user in their
    # own excluded set.
    @cohort_gender_hidden_user_ids =
      (excluded_by_me.pluck(:id) + excluding_me.pluck(:id)).uniq - [ id ]
  end

  private

  # Admins see all content, and members can filter out the other side of the
  # community but never their own.
  def cohort_gender_privacy_is_permitted
    if admin? && !cohort_gender_privacy_all_members?
      errors.add(:cohort_gender_privacy, "isn't available to admin accounts, which see all content")
    elsif cohort_gender_privacy_men_only? && female_cohort_member?
      errors.add(:cohort_gender_privacy, "can't hide female cohort members' content while you are one")
    elsif cohort_gender_privacy_women_only? && male_cohort_member?
      errors.add(:cohort_gender_privacy, "can't hide male cohort members' content while you are one")
    end
  end
end
