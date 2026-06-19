# Seed identifiers are listed in dependency order so child records can reference
# their parents. Each identifier loads its matching files from db/seeds/<identifier>
# and db/seeds/<Rails.env>/<identifier>; identifiers without files for the current
# environment are simply skipped (e.g. only the test env defines membership/reaction
# seeds, while development builds those inline within its post/group seed files).
Oaken.seed :users, :cohorts, :cohort_memberships,
  :groups, :group_memberships,
  :posts, :post_comments,
  :feed_posts, :feed_post_comments,
  :group_posts, :group_post_comments,
  :conversations, :conversation_participants,
  :notifications, :faqs,
  :help_requests, :help_request_replies,
  :reactions, :push_subscriptions, :user_blocks, :releases
