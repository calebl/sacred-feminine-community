require "test_helper"

class Api::V1::MeControllerTest < ActionDispatch::IntegrationTest
  include ApiExamples

  setup do
    @api_token = ApiToken.issue!(user: users.attendee, device_name: "iPhone")
  end

  test "returns the signed-in member" do
    get api_v1_me_path, headers: api_headers(@api_token.token)

    assert_response :success
    user = response.parsed_body["user"]
    assert_equal users.attendee.id, user["id"]
    assert_equal "jane@example.com", user["email"]
    assert_equal users.attendee.total_unread_count, user["unread_notification_count"]
    write_api_example("me_show")
  end

  test "includes an avatar path when the member has an avatar" do
    users.attendee.avatar.attach(io: file_fixture("avatar.png").open, filename: "avatar.png", content_type: "image/png")

    get api_v1_me_path, headers: api_headers(@api_token.token)

    assert_match %r{\A/rails/active_storage/representations/}, response.parsed_body["user"]["avatar_path"]
  end

  test "records when the token was last used" do
    get api_v1_me_path, headers: api_headers(@api_token.token)

    assert_not_nil @api_token.reload.last_used_at
  end

  test "rejects a missing token" do
    get api_v1_me_path

    assert_response :unauthorized
    assert_match "Bearer", response.headers["WWW-Authenticate"]
  end

  test "rejects an unknown token" do
    get api_v1_me_path, headers: api_headers("not-a-real-token")

    assert_response :unauthorized
  end

  test "rejects the token of a removed member" do
    token = @api_token.token
    users.attendee.update_column(:discarded_at, Time.current)

    get api_v1_me_path, headers: api_headers(token)

    assert_response :unauthorized
  end

  test "ignores the website's cookie session" do
    sign_in users.attendee

    get api_v1_me_path

    assert_response :unauthorized
  end

  test "the website does not accept API tokens" do
    get feed_posts_path, headers: api_headers(@api_token.token)

    assert_redirected_to new_user_session_path
  end
end
