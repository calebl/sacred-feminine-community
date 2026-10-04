# A sign-in token for the native app, one per signed-in device. Only a SHA-256
# digest of the token is stored; the raw value is handed out once at sign-in
# and cannot be recovered afterwards. Deleting the row signs that device out.
class ApiToken < ApplicationRecord
  # How stale last_used_at may get before a request refreshes it, so every API
  # call does not write to the database.
  LAST_USED_RESOLUTION = 1.minute

  belongs_to :user

  validates :device_name, presence: true, length: { maximum: 100 }
  validates :token_digest, presence: true, uniqueness: true

  attr_reader :token

  # Builds and saves a token for the device, exposing the raw value through
  # #token on the returned record only.
  def self.issue!(user:, device_name:)
    raw = SecureRandom.base58(32)
    create!(user: user, device_name: device_name, token_digest: digest(raw)).tap do |api_token|
      api_token.instance_variable_set(:@token, raw)
    end
  end

  # The token for a raw bearer value, or nil. Lookup is by digest, so the raw
  # value is never compared in the database.
  def self.authenticate(raw)
    return if raw.blank?

    find_by(token_digest: digest(raw))
  end

  def self.digest(raw)
    OpenSSL::Digest::SHA256.hexdigest(raw)
  end

  def touch_last_used
    return if last_used_at && last_used_at > LAST_USED_RESOLUTION.ago

    update_column(:last_used_at, Time.current)
  end
end
