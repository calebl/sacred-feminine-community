reactions.create :admin_thumbs_up_post,
  reactable: posts.attendee_post, user: users.admin, emoji: "👍", created_at: 1.hour.ago

reactions.create :attendee_heart_post,
  reactable: posts.attendee_post, user: users.attendee, emoji: "❤️", created_at: 30.minutes.ago

reactions.create :admin_fire_feed_post,
  reactable: feed_posts.public_post, user: users.admin, emoji: "🔥", created_at: 1.hour.ago

reactions.create :attendee_thumbs_up_comment,
  reactable: post_comments.admin_comment, user: users.attendee, emoji: "👍", created_at: 20.minutes.ago

reactions.create :admin_heart_group_post,
  reactable: group_posts.book_club_post, user: users.admin, emoji: "❤️", created_at: 45.minutes.ago

reactions.create :attendee_pray_group_comment,
  reactable: group_post_comments.admin_group_comment, user: users.attendee, emoji: "🙏", created_at: 15.minutes.ago
