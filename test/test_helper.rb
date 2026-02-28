ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Stub geocoding in tests
Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [{ "latitude" => 40.7128, "longitude" => -74.0060, "city" => "New York", "country" => "United States" }]
)

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
