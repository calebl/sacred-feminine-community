class Cohort < ApplicationRecord
  include Discard::Model

  audited
  has_associated_audits

  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :created_cohorts
  has_many :cohort_memberships
  has_many :members, through: :cohort_memberships, source: :user
  has_many :chat_messages
  has_one_attached :header_image

  validates :name, presence: true
  validate :acceptable_header_image

  def member?(user)
    cohort_memberships.exists?(user_id: user.id)
  end

  def unread_count(user)
    membership = cohort_memberships.find_by(user: user)
    return 0 unless membership

    messages = chat_messages.where.not(user: user)
    if membership.last_read_at
      messages.where("created_at > ?", membership.last_read_at).count
    else
      messages.count
    end
  end

  private

  def acceptable_header_image
    return unless header_image.attached?
    unless header_image.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:header_image, "must be a JPEG, PNG, GIF, or WebP")
    end
    if header_image.blob.byte_size > 10.megabytes
      errors.add(:header_image, "must be less than 10MB")
    end
  end
end
