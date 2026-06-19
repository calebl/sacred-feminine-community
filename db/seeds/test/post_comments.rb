post_comments.create :admin_comment,
  post: posts.attendee_post, user: users.admin,
  body: "Great first post!", created_at: 1.hour.ago

post_comments.create :attendee_comment,
  post: posts.pinned_announcement, user: users.attendee,
  body: "Thank you for the welcome!", created_at: 30.minutes.ago

post_comments.create :reply_to_admin_comment,
  post: posts.attendee_post, user: users.attendee, parent: post_comments.admin_comment,
  body: "Thanks for the feedback!", created_at: 30.minutes.ago

post_comments.create :nested_reply,
  post: posts.attendee_post, user: users.admin, parent: post_comments.reply_to_admin_comment,
  body: "You're welcome!", created_at: 15.minutes.ago
