require "test_helper"

class Api::VapidKeysControllerTest < ActionDispatch::IntegrationTest
  test "returns vapid public key for authenticated user" do
    sign_in users(:admin)
    get api_vapid_key_path, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_includes json.keys, "public_key"
  end

  test "rejects unauthenticated user" do
    get api_vapid_key_path, as: :json
    assert_response :unauthorized
  end
end
