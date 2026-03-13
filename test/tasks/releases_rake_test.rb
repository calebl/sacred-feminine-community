require "test_helper"
require "rake"
require "base64"

class ReleasesRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("releases:record")
    Rake::Task["releases:record"].reenable
  end

  test "creates a release record by decoding base64 changelog" do
    version = "v2026.03.12.120000"
    commit_sha = "abc123def456"
    changelog = "- Add new feature\n- Fix a bug"
    encoded_changelog = Base64.strict_encode64(changelog)
    deployed_at = "2026-03-12 12:00:00"

    assert_difference "Release.count", 1 do
      capture_io { Rake::Task["releases:record"].invoke(version, commit_sha, encoded_changelog, deployed_at) }
    end

    release = Release.last
    assert_equal version, release.version
    assert_equal commit_sha, release.commit_sha
    assert_equal changelog, release.changelog
    assert_equal Time.zone.parse(deployed_at), release.deployed_at
  end

  test "prints confirmation message" do
    Rake::Task["releases:record"].reenable

    encoded_changelog = Base64.strict_encode64("- Something changed")

    output = capture_io do
      Rake::Task["releases:record"].invoke("v2026.03.12.130000", "fff999aaa111", encoded_changelog, "2026-03-12 13:00:00")
    end

    assert_match(/Recorded release v2026\.03\.12\.130000/, output.first)
  end

  test "preserves multiline changelog through base64 encoding" do
    Rake::Task["releases:record"].reenable

    changelog = "- First change\n- Second change\n- Third change"
    encoded_changelog = Base64.strict_encode64(changelog)

    capture_io do
      Rake::Task["releases:record"].invoke("v2026.03.12.140000", "aabbccddee11", encoded_changelog, "2026-03-12 14:00:00")
    end

    assert_equal changelog, Release.last.changelog
  end
end
