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

# Seeding creates records through their normal model callbacks, which enqueue
# jobs (geocoding, notifications, unread-badge broadcasts). When the ActiveJob
# test adapter is active these enqueues would otherwise linger and leak into the
# first job-aware test (especially when the suite runs without parallelization,
# where seeding happens once up front). Drop them so each test starts clean.
if (adapter = ActiveJob::Base.queue_adapter).respond_to?(:enqueued_jobs)
  adapter.enqueued_jobs.clear
  adapter.performed_jobs.clear
end
