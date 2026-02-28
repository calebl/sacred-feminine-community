class User < ApplicationRecord
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { attendee: 0, admin: 1 }

  has_many :cohort_memberships, dependent: :destroy
  has_many :cohorts, through: :cohort_memberships
  has_many :chat_messages, dependent: :destroy
  has_many :created_cohorts, class_name: "Cohort", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :creator

  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_direct_messages, class_name: "DirectMessage", foreign_key: :sender_id, dependent: :destroy, inverse_of: :sender

  has_one_attached :avatar

  geocoded_by :full_location
  after_validation :geocode, if: ->(u) { u.persisted? && (u.city_changed? || u.country_changed?) }

  validates :name, presence: true

  def full_location
    [ city, country ].compact.join(", ")
  end
end
