require "test_helper"

class ReleaseTest < ActiveSupport::TestCase
  test "valid with all attributes" do
    release = Release.new(
      version: "v2026.03.07.999",
      commit_sha: "aaa1234567890abcdef1234567890abcdef123456",
      changelog: "- Some change",
      deployed_at: Time.current
    )
    assert release.valid?
  end

  test "requires version" do
    release = Release.new(commit_sha: "abc123", changelog: "changes", deployed_at: Time.current)
    assert_not release.valid?
    assert_includes release.errors[:version], "can't be blank"
  end

  test "requires commit_sha" do
    release = Release.new(version: "v1", changelog: "changes", deployed_at: Time.current)
    assert_not release.valid?
    assert_includes release.errors[:commit_sha], "can't be blank"
  end

  test "requires changelog" do
    release = Release.new(version: "v1", commit_sha: "abc123", deployed_at: Time.current)
    assert_not release.valid?
    assert_includes release.errors[:changelog], "can't be blank"
  end

  test "requires deployed_at" do
    release = Release.new(version: "v1", commit_sha: "abc123", changelog: "changes")
    assert_not release.valid?
    assert_includes release.errors[:deployed_at], "can't be blank"
  end

  test "enforces unique version" do
    existing = releases(:v1)
    duplicate = Release.new(
      version: existing.version,
      commit_sha: "newsha123",
      changelog: "new changes",
      deployed_at: Time.current
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:version], "has already been taken"
  end

  test "recent scope orders by deployed_at descending" do
    releases = Release.recent
    assert_equal releases(:v2), releases.first
    assert_equal releases(:v1), releases.second
  end

  test "generate_changelog returns non-empty changelog" do
    commit_sha = `git rev-parse HEAD`.strip
    changelog = Release.generate_changelog(version: "v_nonexistent", commit_sha: commit_sha)
    assert changelog.present?, "Expected a non-empty changelog"
  end

  test "generate_changelog strips PR numbers" do
    commit_sha = `git rev-parse HEAD`.strip
    changelog = Release.generate_changelog(version: "v_nonexistent", commit_sha: commit_sha)
    assert_no_match(/\(#\d+\)/, changelog, "PR numbers should be stripped from changelog")
  end

  test "generate_changelog returns fallback for empty range" do
    head_sha = `git rev-parse HEAD`.strip
    system("git tag v_test_empty #{head_sha}", exception: true)

    begin
      # Create a second tag at the same commit so the range is empty
      system("git tag v_test_empty2 #{head_sha}", exception: true)
      changelog = Release.generate_changelog(version: "v_test_empty2", commit_sha: head_sha)
      assert_equal "- No changes since last release", changelog
    ensure
      system("git tag -d v_test_empty", out: File::NULL, err: File::NULL)
      system("git tag -d v_test_empty2", out: File::NULL, err: File::NULL)
    end
  end

  test "generate_changelog formats entries as bullet list" do
    commit_sha = `git rev-parse HEAD`.strip
    changelog = Release.generate_changelog(version: "v_nonexistent", commit_sha: commit_sha)
    changelog.each_line do |line|
      assert_match(/\A- /, line.strip, "Each changelog line should start with '- '")
    end
  end
end
