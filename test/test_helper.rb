ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :branch
  end
end

require_relative "../config/environment"
require "rails/test_help"

# Stub geocoding in tests
Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [ { "latitude" => 40.7128, "longitude" => -74.0060, "city" => "New York", "country" => "United States" } ]
)

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    if ENV["COVERAGE"]
      parallelize_setup do |worker|
        SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
      end

      parallelize_teardown do |worker|
        SimpleCov.result
      end
    end

    # Test data is provided entirely by Oaken seeds (db/seeds + db/seeds/test).
    # Records are reached via dot notation — `users.admin`, `cohorts.kabul_retreat` —
    # rather than Rails fixture accessors. test_setup relies on fixtures' transactional
    # wrapping internally, so each test still runs inside a rolled-back transaction.
    include Oaken.loader.test_setup
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
