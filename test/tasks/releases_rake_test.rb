require "test_helper"
require "rake"

class ReleasesRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("releases:record")
    Rake::Task["releases:record"].reenable
  end

  test "creates a release record from rake arguments" do
    version = "v2026.03.12.120000"
    commit_sha = `git rev-parse HEAD`.strip
    deployed_at = "2026-03-12 12:00:00"

    assert_difference "Release.count", 1 do
      capture_io { Rake::Task["releases:record"].invoke(version, commit_sha, deployed_at) }
    end

    release = Release.last
    assert_equal version, release.version
    assert_equal commit_sha, release.commit_sha
    assert release.changelog.present?, "Expected changelog to be generated"
    assert_equal Time.zone.parse(deployed_at), release.deployed_at
  end

  test "prints confirmation message" do
    Rake::Task["releases:record"].reenable
    commit_sha = `git rev-parse HEAD`.strip

    output = capture_io do
      Rake::Task["releases:record"].invoke("v2026.03.12.130000", commit_sha, "2026-03-12 13:00:00")
    end

    assert_match(/Recorded release v2026\.03\.12\.130000/, output.first)
  end
end
