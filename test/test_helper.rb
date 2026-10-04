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

# Request tests for the native app's JSON API save their responses here as
# example files. The app's Swift tests decode the same files, so a change to an
# API shape fails a test on one side or the other. Timestamps and tokens are
# replaced with fixed values, and record ids renumbered in order of first
# appearance (each parallel test database numbers its records differently), so
# the files only change when a shape does. References survive renumbering: the
# same id always becomes the same number within a file.
module ApiExamples
  DIR = Rails.root.join("test/api_examples/v1")
  EXAMPLE_TIME = "2026-01-01T12:00:00.000Z"
  EXAMPLE_TOKEN = "example-api-token"

  def write_api_example(name)
    DIR.mkpath
    @api_example_ids = {}
    DIR.join("#{name}.json").write(JSON.pretty_generate(normalize_api_example(response.parsed_body)) + "\n")
  end

  def api_headers(token)
    { "Authorization" => "Bearer #{token}" }
  end

  private

  def normalize_api_example(value, key = nil, id_domain: nil)
    case value
    when Hash
      domain = api_example_domain(value)
      value.to_h { |k, v| [ k, normalize_api_example(v, k, id_domain: (domain if k.to_s == "id")) ] }
    when Array then value.map { |v| normalize_api_example(v) }
    else
      if key.to_s.end_with?("_at") && value.present? then EXAMPLE_TIME
      elsif value.is_a?(Integer) && (domain = id_domain || api_example_reference_domain(key.to_s))
        @api_example_ids[[ domain, value ]] ||= @api_example_ids.count { |(stored_domain, _), _| stored_domain == domain } + 1
      elsif key.to_s == "token" then EXAMPLE_TOKEN
      # Active Storage paths carry signed ids that change with every upload.
      elsif key.to_s.end_with?("path") && value.to_s.start_with?("/rails/active_storage/")
        value.sub(%r{\A(/rails/active_storage/[a-z]+/[a-z]+/)[^/]+/}, "\\1example-signed-id/")
      else value
      end
    end
  end

  def api_example_domain(value)
    if value.key?("post_id") then :comment
    elsif value.key?("kind") then :post
    elsif value.key?("email") || value.key?("role") || value.key?("bio") || value.key?("removed") then :user
    elsif value.key?("content_type") && value.key?("path") then :attachment
    elsif value.key?("name") && value.key?("created_at") then :device
    else :record
    end
  end

  def api_example_reference_domain(key)
    case key
    when "post_id", "next_cursor" then :post
    when "parent_id" then :comment
    when "user_id" then :user
    end
  end
end
