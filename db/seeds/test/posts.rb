posts.create :pinned_announcement,
  body: "Welcome to our retreat! We are excited to have you.",
  cohort: cohorts.kabul_retreat, user: users.admin, pinned: true, created_at: 2.days.ago

posts.create :attendee_post,
  body: "This is my first post in the cohort.",
  cohort: cohorts.kabul_retreat, user: users.attendee, pinned: false, created_at: 1.day.ago

posts.create :bali_post,
  body: "Here is an update on the Bali retreat plans.",
  cohort: cohorts.bali_retreat, user: users.admin, pinned: false, created_at: 1.hour.ago
