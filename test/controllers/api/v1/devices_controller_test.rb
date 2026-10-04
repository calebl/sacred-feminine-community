require "test_helper"

class Api::V1::DevicesControllerTest < ActionDispatch::IntegrationTest
  include ApiExamples

  setup do
    @current = ApiToken.issue!(user: users.attendee, device_name: "Jane's iPhone")
    @other = ApiToken.issue!(user: users.attendee, device_name: "Jane's iPad")
    @someone_else = ApiToken.issue!(user: users.admin, device_name: "Admin iPhone")
  end

  test "lists only the member's own devices and marks the current one" do
    get api_v1_devices_path, headers: api_headers(@current.token)

    assert_response :success
    devices = response.parsed_body["devices"]
    assert_equal [ @current.id, @other.id ].sort, devices.map { |d| d["id"] }.sort
    assert devices.find { |d| d["id"] == @current.id }["current"]
    assert_not devices.find { |d| d["id"] == @other.id }["current"]
    write_api_example("devices_index")
  end

  test "revokes another of the member's devices" do
    delete api_v1_device_path(@other), headers: api_headers(@current.token)

    assert_response :no_content
    assert_not ApiToken.exists?(@other.id)

    get api_v1_me_path, headers: api_headers(@other.token)
    assert_response :unauthorized
  end

  test "cannot revoke someone else's device" do
    delete api_v1_device_path(@someone_else), headers: api_headers(@current.token)

    assert_response :not_found
    assert ApiToken.exists?(@someone_else.id)
    write_api_example("error_not_found")
  end
end
