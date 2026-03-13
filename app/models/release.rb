class Release < ApplicationRecord
  validates :version, presence: true, uniqueness: true
  validates :commit_sha, presence: true
  validates :changelog, presence: true
  validates :deployed_at, presence: true

  scope :recent, -> { order(deployed_at: :desc) }
end
