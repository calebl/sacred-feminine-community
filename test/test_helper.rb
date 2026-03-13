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

    fixtures :all

    # Oaken's test_setup is intentionally excluded here. Including
    # `Oaken.loader.test_setup` defines accessor methods (e.g. `users`, `cohorts`)
    # that conflict with Rails fixture accessors of the same name. Fixture accessors
    # accept a symbol argument — `users(:attendee)` — while Oaken's accessors take
    # no arguments and use dot notation — `users.admin`. With both active, Oaken's
    # method wins and every `users(:attendee)` call raises an ArgumentError.
    #
    # To adopt Oaken in tests, either:
    #   1. Register models under distinct names (`register :seed_users, User`) so
    #      the Oaken accessor (`seed_users.admin`) doesn't shadow the fixture method.
    #   2. Migrate fully from fixtures to Oaken seeds, replacing all
    #      `model(:fixture_key)` calls with `model.label` dot-notation.
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
