cohort_memberships.create :admin_in_kabul, user: users.admin, cohort: cohorts.kabul_retreat
cohort_memberships.create :attendee_in_kabul, user: users.attendee, cohort: cohorts.kabul_retreat
cohort_memberships.create :admin_in_bali, user: users.admin, cohort: cohorts.bali_retreat
cohort_memberships.create :attendee_in_bali, user: users.attendee, cohort: cohorts.bali_retreat
cohort_memberships.create :male_member_in_mens, user: users.male_member, cohort: cohorts.mens_gathering
cohort_memberships.create :men_only_member_in_mens, user: users.men_only_member, cohort: cohorts.mens_gathering
# Also in the women's cohort so a single cohort feed carries both sides' content.
cohort_memberships.create :male_member_in_kabul, user: users.male_member, cohort: cohorts.kabul_retreat
cohort_memberships.create :women_only_member_in_kabul, user: users.women_only_member, cohort: cohorts.kabul_retreat
cohort_memberships.create :men_only_member_in_kabul, user: users.men_only_member, cohort: cohorts.kabul_retreat
