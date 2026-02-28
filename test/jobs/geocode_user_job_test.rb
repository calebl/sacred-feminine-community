require "test_helper"

class GeocodeUserJobTest < ActiveJob::TestCase
  test "geocodes user and saves coordinates" do
    user = users(:attendee)
    user.update_columns(latitude: nil, longitude: nil)

    GeocodeUserJob.perform_now(user.id)

    user.reload
    assert_not_nil user.latitude
    assert_not_nil user.longitude
  end
end
