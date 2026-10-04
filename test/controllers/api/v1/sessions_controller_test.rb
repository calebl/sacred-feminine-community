require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  include ApiExamples

  test "signs in with email and password and returns a token for the device" do
    assert_difference -> { users.attendee.api_tokens.count }, 1 do
      post api_v1_session_path, params: { email: "Jane@Example.com ", password: "password123", device_name: "Jane's iPhone" }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert body["token"].present?
    assert_equal "Jane's iPhone", body["device"]["name"]
    assert body["device"]["current"]
    assert_equal users.attendee.id, body["user"]["id"]
    assert_equal "jane@example.com", body["user"]["email"]
    write_api_example("session_create")
  end

  test "stores only a digest of the token" do
    post api_v1_session_path, params: { email: "jane@example.com", password: "password123", device_name: "iPhone" }, as: :json

    token = response.parsed_body["token"]
    api_token = users.attendee.api_tokens.sole
    assert_not_equal token, api_token.token_digest
    assert_equal api_token, ApiToken.authenticate(token)
  end

  test "rejects a wrong password" do
    assert_no_difference -> { ApiToken.count } do
      post api_v1_session_path, params: { email: "jane@example.com", password: "wrong", device_name: "iPhone" }, as: :json
    end

    assert_response :unauthorized
    assert_equal "Invalid email or password.", response.parsed_body["error"]
    write_api_example("error_unauthorized")
  end

  test "rejects an unknown email with the same message" do
    post api_v1_session_path, params: { email: "nobody@example.com", password: "password123", device_name: "iPhone" }, as: :json

    assert_response :unauthorized
    assert_equal "Invalid email or password.", response.parsed_body["error"]
  end

  test "rejects a removed member" do
    users.attendee.discard!

    post api_v1_session_path, params: { email: "jane@example.com", password: "password123", device_name: "iPhone" }, as: :json

    assert_response :unauthorized
    assert_equal 0, ApiToken.count
  end

  test "requires a device name" do
    post api_v1_session_path, params: { email: "jane@example.com", password: "password123" }, as: :json

    assert_response :bad_request
  end

  test "rate limits sign-in attempts" do
    # The test cache is a null store, so simulate a client already over the limit.
    Rails.cache.define_singleton_method(:increment) { |*| 11 }
    begin
      post api_v1_session_path, params: { email: "jane@example.com", password: "password123", device_name: "iPhone" }, as: :json
    ensure
      Rails.cache.singleton_class.remove_method(:increment)
    end

    assert_response :too_many_requests
    assert_equal 0, ApiToken.count
  end

  test "signing out revokes only the current device" do
    current = ApiToken.issue!(user: users.attendee, device_name: "iPhone")
    other = ApiToken.issue!(user: users.attendee, device_name: "iPad")

    delete api_v1_session_path, headers: api_headers(current.token)

    assert_response :no_content
    assert_not ApiToken.exists?(current.id)
    assert ApiToken.exists?(other.id)

    get api_v1_me_path, headers: api_headers(current.token)
    assert_response :unauthorized
  end

  test "signing out requires a token" do
    delete api_v1_session_path

    assert_response :unauthorized
  end
end
