require "test_helper"

class PostNotifiableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test "cohort post enqueues new_post notifications for other members" do
    cohort = cohorts(:kabul_retreat)
    author = users(:admin)
    other_member = users(:attendee)

    enqueued = []
    assert_enqueued_with(job: CreateNotificationJob) do
      Post.create!(cohort: cohort, user: author, body: "Hello cohort")
    end

    enqueued = enqueued_jobs.select { |j| j["job_class"] == "CreateNotificationJob" }
    recipient_ids = enqueued.map { |j| j["arguments"].last["user_id"] }

    assert_includes recipient_ids, other_member.id
    assert_not_includes recipient_ids, author.id
    event_types = enqueued.map { |j| j["arguments"].last["event_type"] }
    assert_includes event_types, "new_post"
  end

  test "cohort post does not notify the author" do
    cohort = cohorts(:kabul_retreat)
    author = users(:admin)

    Post.create!(cohort: cohort, user: author, body: "My own post")

    new_post_jobs = enqueued_jobs.select do |j|
      j["job_class"] == "CreateNotificationJob" &&
        j["arguments"].last["event_type"] == "new_post"
    end

    recipient_ids = new_post_jobs.map { |j| j["arguments"].last["user_id"] }
    assert_not_includes recipient_ids, author.id
  end

  test "cohort post does not duplicate notifications for mentioned users" do
    cohort = cohorts(:kabul_retreat)
    author = users(:admin)
    mentioned = users(:attendee)

    Post.create!(cohort: cohort, user: author, body: "Hey @[#{mentioned.name}](#{mentioned.id})")

    jobs = enqueued_jobs.select { |j| j["job_class"] == "CreateNotificationJob" }
    new_post_recipients = jobs.select { |j| j["arguments"].last["event_type"] == "new_post" }
                              .map { |j| j["arguments"].last["user_id"] }

    assert_not_includes new_post_recipients, mentioned.id
  end

  test "group post enqueues new_post notifications for other members" do
    group = groups(:book_club)
    author = users(:attendee)
    other_member = users(:admin)

    GroupPost.create!(group: group, user: author, body: "Hello group")

    jobs = enqueued_jobs.select { |j| j["job_class"] == "CreateNotificationJob" && j["arguments"].last["event_type"] == "new_post" }
    recipient_ids = jobs.map { |j| j["arguments"].last["user_id"] }

    assert_includes recipient_ids, other_member.id
    assert_not_includes recipient_ids, author.id
  end

  test "new_post notification body is generic (no post body content)" do
    cohort = cohorts(:kabul_retreat)
    Post.create!(cohort: cohort, user: users(:admin), body: "SECRET CONTENT that should never leak")

    jobs = enqueued_jobs.select { |j| j["arguments"].last["event_type"] == "new_post" }
    assert jobs.any?
    jobs.each do |j|
      body = j["arguments"].last["body"]
      assert_no_match(/SECRET CONTENT/, body)
      assert_equal "Posted in #{cohort.name}", body
    end
  end

  test "notification path points to the post" do
    cohort = cohorts(:kabul_retreat)
    post = Post.create!(cohort: cohort, user: users(:admin), body: "Hello")

    jobs = enqueued_jobs.select { |j| j["arguments"].last["event_type"] == "new_post" }
    jobs.each do |j|
      assert_equal "/cohorts/#{cohort.id}/posts/#{post.id}", j["arguments"].last["path"]
    end
  end
end
