require "test_helper"

class Api::V1::FeedPostsControllerTest < ActionDispatch::IntegrationTest
  include ApiExamples

  def token_for(user)
    ApiToken.issue!(user: user, device_name: "iPhone").token
  end

  test "lists feed posts newest first" do
    get api_v1_feed_posts_path, headers: api_headers(token_for(users.attendee))

    assert_response :success
    ids = response.parsed_body["posts"].map { |p| p["id"] }
    assert_equal FeedPost.visible_to(users.attendee).order(id: :desc).pluck(:id), ids
    assert_nil response.parsed_body["next_cursor"]
    write_api_example("feed_posts_index")
  end

  test "pages with a cursor" do
    token = token_for(users.admin)
    all_ids = FeedPost.visible_to(users.admin).order(id: :desc).pluck(:id)

    get api_v1_feed_posts_path(limit: 2), headers: api_headers(token)
    first_page = response.parsed_body
    assert_equal all_ids.first(2), first_page["posts"].map { |p| p["id"] }
    assert_equal all_ids[1], first_page["next_cursor"]

    get api_v1_feed_posts_path(limit: 2, before: first_page["next_cursor"]), headers: api_headers(token)
    assert_equal all_ids[2, 2], response.parsed_body["posts"].map { |p| p["id"] }
  end

  test "returns a null cursor on the last page" do
    count = FeedPost.visible_to(users.admin).count

    get api_v1_feed_posts_path(limit: count), headers: api_headers(token_for(users.admin))

    assert_equal count, response.parsed_body["posts"].size
    assert_nil response.parsed_body["next_cursor"]
  end

  test "hides posts from a blocked member" do
    UserBlock.create!(blocker: users.attendee, blocked: users.male_member)

    get api_v1_feed_posts_path, headers: api_headers(token_for(users.attendee))

    ids = response.parsed_body["posts"].map { |p| p["id"] }
    assert_not_includes ids, feed_posts.male_member_feed_post.id
  end

  test "hides posts excluded by the cohort gender filter" do
    get api_v1_feed_posts_path, headers: api_headers(token_for(users.women_only_member))

    ids = response.parsed_body["posts"].map { |p| p["id"] }
    assert_not_includes ids, feed_posts.male_member_feed_post.id
    assert_includes ids, feed_posts.attendee_feed_post.id
  end

  test "post shape includes the author, counts and permissions" do
    get api_v1_feed_posts_path, headers: api_headers(token_for(users.attendee))

    post = response.parsed_body["posts"].find { |p| p["id"] == feed_posts.attendee_feed_post.id }
    assert_equal "feed", post["kind"]
    assert_equal users.attendee.id, post["author"]["id"]
    assert post["can_edit"]
    assert post["can_delete"]

    admin_post = response.parsed_body["posts"].find { |p| p["id"] == feed_posts.public_post.id }
    assert_not admin_post["can_edit"]
    assert_equal 3, admin_post["comment_count"]
  end

  test "shows a post with its nested comments" do
    get api_v1_feed_post_path(feed_posts.public_post), headers: api_headers(token_for(users.attendee))

    assert_response :success
    post = response.parsed_body["post"]
    comment = post["comments"].sole
    assert_equal feed_post_comments.admin_feed_comment.id, comment["id"]
    reply = comment["replies"].sole
    assert_equal feed_post_comments.reply_to_admin_feed_comment.id, reply["id"]
    assert_equal feed_post_comments.nested_feed_reply.id, reply["replies"].sole["id"]
    write_api_example("feed_post_show")
  end

  test "drops replies from hidden members" do
    get api_v1_feed_post_path(feed_posts.pinned_feed_post), headers: api_headers(token_for(users.women_only_member))

    comments = response.parsed_body["post"]["comments"]
    thread = comments.find { |c| c["id"] == feed_post_comments.feed_thread_parent.id }
    assert_empty thread["replies"]
  end

  test "resolves mentions, leaving hidden members as plain text" do
    post = FeedPost.create!(user: users.admin,
      body: "Hello @[Jane Attendee](#{users.attendee.id}) and @[Michael Member](#{users.male_member.id})")
    post.reactions.create!(user: users.attendee, emoji: "❤️")

    get api_v1_feed_post_path(post), headers: api_headers(token_for(users.women_only_member))

    body = response.parsed_body["post"]
    assert_equal "Hello @Jane Attendee and @Michael Member", body["body"]
    assert_equal [ { "user_id" => users.attendee.id, "name" => "Jane Attendee" } ], body["mentions"]
    assert_equal [ { "emoji" => "❤️", "count" => 1, "reacted_by_me" => false } ], body["reactions"]
  end

  test "includes photo paths" do
    post = feed_posts.attendee_feed_post
    post.photos.attach(io: file_fixture("avatar.png").open, filename: "photo.png", content_type: "image/png")

    get api_v1_feed_post_path(post), headers: api_headers(token_for(users.attendee))

    photo = response.parsed_body["post"]["photos"].sole
    assert_equal "image/png", photo["content_type"]
    assert_match %r{\A/rails/active_storage/blobs/}, photo["path"]
    write_api_example("feed_post_show_with_photo")
  end

  test "returns not found for a post hidden from the member" do
    get api_v1_feed_post_path(feed_posts.male_member_feed_post), headers: api_headers(token_for(users.women_only_member))

    assert_response :not_found
  end

  test "requires a token" do
    get api_v1_feed_posts_path

    assert_response :unauthorized
  end
end
