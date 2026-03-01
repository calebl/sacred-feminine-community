require "test_helper"

class Api::MapPinsControllerTest < ActionDispatch::IntegrationTest
  test "returns only opted-in users with coordinates" do
    # Set coordinates on opted-in users
    users(:admin).update!(latitude: 34.0522, longitude: -118.2437)
    users(:attendee).update!(latitude: 48.8566, longitude: 2.3522)

    sign_in users(:attendee)
    get api_map_pins_path(format: :json)
    assert_response :success

    pins = JSON.parse(response.body)

    # admin and attendee have show_on_map: true, attendee_two has show_on_map: false
    assert_equal 2, pins.length

    names = pins.map { |p| p["name"] }
    assert_includes names, "Admin User"
    assert_includes names, "Jane Attendee"
    assert_not_includes names, "Sarah Member"
  end

  test "excludes users without coordinates" do
    # attendee has show_on_map: true but no lat/lng set
    sign_in users(:attendee)
    get api_map_pins_path(format: :json)
    assert_response :success

    pins = JSON.parse(response.body)
    assert_equal 0, pins.length
  end

  test "pin includes state field" do
    users(:admin).update!(latitude: 34.0522, longitude: -118.2437)
    sign_in users(:admin)
    get api_map_pins_path(format: :json)

    pins = JSON.parse(response.body)
    admin_pin = pins.find { |p| p["name"] == "Admin User" }
    assert_equal "California", admin_pin["state"]
  end

  test "unauthenticated user gets 401 for json" do
    get api_map_pins_path(format: :json)
    assert_response :unauthorized
  end
end
