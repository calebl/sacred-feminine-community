group_post_comments.create :admin_group_comment,
  group_post: group_posts.book_club_post, user: users.admin,
  body: "Great book recommendation!", created_at: 1.hour.ago

group_post_comments.create :attendee_group_comment,
  group_post: group_posts.book_club_pinned, user: users.attendee,
  body: "Thanks for the welcome!", created_at: 30.minutes.ago

group_post_comments.create :reply_to_admin_group_comment,
  group_post: group_posts.book_club_post, user: users.attendee, parent: group_post_comments.admin_group_comment,
  body: "Thanks for the feedback!", created_at: 30.minutes.ago

group_post_comments.create :nested_group_reply,
  group_post: group_posts.book_club_post, user: users.admin, parent: group_post_comments.reply_to_admin_group_comment,
  body: "You're welcome!", created_at: 15.minutes.ago
