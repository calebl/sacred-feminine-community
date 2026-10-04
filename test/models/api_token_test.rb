require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  test ".issue! returns the raw token once and stores its digest" do
    api_token = ApiToken.issue!(user: users.attendee, device_name: "iPhone")

    assert api_token.token.present?
    assert_equal ApiToken.digest(api_token.token), api_token.token_digest
    assert_nil ApiToken.find(api_token.id).token
  end

  test ".authenticate finds a token by its raw value" do
    api_token = ApiToken.issue!(user: users.attendee, device_name: "iPhone")

    assert_equal api_token, ApiToken.authenticate(api_token.token)
    assert_nil ApiToken.authenticate("wrong")
    assert_nil ApiToken.authenticate(nil)
  end

  test "requires a device name" do
    assert_not ApiToken.new(user: users.attendee, token_digest: "x").valid?
  end

  test "#touch_last_used writes at most once a minute" do
    api_token = ApiToken.issue!(user: users.attendee, device_name: "iPhone")
    api_token.touch_last_used
    first = api_token.reload.last_used_at

    travel 30.seconds do
      api_token.touch_last_used
      assert_equal first, api_token.reload.last_used_at
    end

    travel 2.minutes do
      api_token.touch_last_used
      assert_operator api_token.reload.last_used_at, :>, first
    end
  end

  test "changing the password revokes every device" do
    ApiToken.issue!(user: users.attendee, device_name: "iPhone")
    ApiToken.issue!(user: users.attendee, device_name: "iPad")

    users.attendee.update!(password: "newpassword123", password_confirmation: "newpassword123")

    assert_empty users.attendee.api_tokens.reload
  end

  test "other profile changes keep devices signed in" do
    ApiToken.issue!(user: users.attendee, device_name: "iPhone")

    users.attendee.update!(bio: "Hello")

    assert_equal 1, users.attendee.api_tokens.reload.count
  end

  test "removing a member revokes every device" do
    ApiToken.issue!(user: users.attendee, device_name: "iPhone")

    users.attendee.discard!

    assert_empty users.attendee.api_tokens.reload
  end
end
