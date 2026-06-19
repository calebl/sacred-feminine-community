group_posts.create :book_club_pinned,
  body: "Welcome to our book club! Share your favorite reads.",
  group: groups.book_club, user: users.attendee, pinned: true, created_at: 2.days.ago

group_posts.create :book_club_post,
  body: "Just finished an amazing novel.",
  group: groups.book_club, user: users.admin, pinned: false, created_at: 1.day.ago

group_posts.create :yoga_post,
  body: "Morning yoga session was wonderful today.",
  group: groups.yoga_group, user: users.admin, pinned: false, created_at: 1.hour.ago

group_posts.create :reading_group_post,
  body: "What should we read next?",
  group: groups.reading_group, user: users.attendee_two, pinned: false, created_at: 1.hour.ago
