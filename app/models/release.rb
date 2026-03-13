class Release < ApplicationRecord
  validates :version, presence: true, uniqueness: true
  validates :commit_sha, presence: true
  validates :changelog, presence: true
  validates :deployed_at, presence: true

  scope :recent, -> { order(deployed_at: :desc) }

  def self.generate_changelog(version:, commit_sha:)
    previous_tag = `git tag -l "v*" --sort=-version:refname`.lines.map(&:strip).find { |t| t != version }

    changelog = if previous_tag
      `git log --pretty=format:"- %s" #{previous_tag}..#{commit_sha}`.gsub(/ \(#\d+\)/, "")
    else
      `git log --pretty=format:"- %s" -20 #{commit_sha}`.gsub(/ \(#\d+\)/, "")
    end

    changelog.presence || "- No changes since last release"
  end
end
