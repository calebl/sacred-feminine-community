class User < ApplicationRecord
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { attendee: 0, admin: 1 }

  has_many :cohort_memberships, dependent: :destroy
  has_many :cohorts, through: :cohort_memberships
  has_many :chat_messages, dependent: :destroy
  has_many :created_cohorts, class_name: "Cohort", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :creator
  has_many :announcements, foreign_key: :created_by_id, dependent: :nullify, inverse_of: :creator

  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_direct_messages, class_name: "DirectMessage", foreign_key: :sender_id, dependent: :destroy, inverse_of: :sender

  has_one_attached :avatar

  geocoded_by :full_location
  after_commit :enqueue_geocode, if: -> { saved_change_to_city? || saved_change_to_country? }

  validates :name, presence: true
  validate :acceptable_avatar

  def full_location
    [ city, country ].compact.join(", ")
  end

  private

  def enqueue_geocode
    GeocodeUserJob.perform_later(id)
  end

  def acceptable_avatar
    return unless avatar.attached?
    unless avatar.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:avatar, "must be a JPEG, PNG, GIF, or WebP")
    end
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end
  end
end
