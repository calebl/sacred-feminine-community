require "test_helper"

class GeocodeUserJobTest < ActiveJob::TestCase
  test "geocodes user and saves coordinates" do
    user = users.attendee
    user.update_columns(latitude: nil, longitude: nil)

    GeocodeUserJob.perform_now(user.id)

    user.reload
    assert_not_nil user.latitude
    assert_not_nil user.longitude
  end

  test "does nothing if user was deleted" do
    user = User.create!(name: "Deleted User", email: "deleted-geocode@example.test", password: "password123")
    user_id = user.id
    user.destroy!

    assert_nil GeocodeUserJob.perform_now(user_id)
  end
end
