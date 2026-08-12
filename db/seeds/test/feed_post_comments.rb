feed_post_comments.create :admin_feed_comment,
  feed_post: feed_posts.public_post, user: users.admin,
  body: "Great to have everyone here!", created_at: 1.hour.ago

feed_post_comments.create :attendee_feed_comment,
  feed_post: feed_posts.pinned_feed_post, user: users.attendee,
  body: "Thanks for the welcome!", created_at: 30.minutes.ago

feed_post_comments.create :reply_to_admin_feed_comment,
  feed_post: feed_posts.public_post, user: users.attendee, parent: feed_post_comments.admin_feed_comment,
  body: "Thanks for the feedback!", created_at: 20.minutes.ago

feed_post_comments.create :nested_feed_reply,
  feed_post: feed_posts.public_post, user: users.admin, parent: feed_post_comments.reply_to_admin_feed_comment,
  body: "You're welcome!", created_at: 15.minutes.ago

# Nested reply filtering needs a case on this side too. Given its own parent
# rather than hung off admin_feed_comment, whose subtree size the cascade-delete
# tests assert. The blocking side of the same rule is already covered by
# reply_to_admin_feed_comment.
feed_post_comments.create :feed_thread_parent,
  feed_post: feed_posts.pinned_feed_post, user: users.admin,
  body: "Kicking off a thread.", created_at: 26.minutes.ago

feed_post_comments.create :male_member_feed_reply,
  feed_post: feed_posts.pinned_feed_post, user: users.male_member, parent: feed_post_comments.feed_thread_parent,
  body: "A nested reply from a male cohort member.", created_at: 10.minutes.ago
