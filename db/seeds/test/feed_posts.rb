feed_posts.create :public_post,
  body: "A post visible to all community members.",
  user: users.admin, pinned: false, created_at: 1.day.ago

feed_posts.create :pinned_feed_post,
  body: "Welcome to the community feed! Please introduce yourself.",
  user: users.admin, pinned: true, created_at: 2.days.ago

feed_posts.create :attendee_feed_post,
  body: "Hello everyone, excited to be here!",
  user: users.attendee, pinned: false, created_at: 1.hour.ago
