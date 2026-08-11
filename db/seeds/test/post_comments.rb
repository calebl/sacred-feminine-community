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

post_comments.create :male_member_comment,
  post: posts.pinned_announcement, user: users.male_member,
  body: "A comment from a male cohort member.", created_at: 20.minutes.ago

# A visible (admin-authored) parent with a reply from each hiding case beneath
# it. Nested replies have to be filtered like top-level comments, and each reply
# doubles as the positive control for the other's test.
post_comments.create :announcement_comment,
  post: posts.pinned_announcement, user: users.admin,
  body: "Glad you could all make it.", created_at: 25.minutes.ago

post_comments.create :attendee_announcement_reply,
  post: posts.pinned_announcement, user: users.attendee, parent: post_comments.announcement_comment,
  body: "A nested reply from the attendee.", created_at: 22.minutes.ago

post_comments.create :male_member_announcement_reply,
  post: posts.pinned_announcement, user: users.male_member, parent: post_comments.announcement_comment,
  body: "A nested reply from a male cohort member.", created_at: 18.minutes.ago
