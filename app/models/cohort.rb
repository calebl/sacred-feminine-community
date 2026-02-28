class Cohort < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :created_cohorts
  has_many :cohort_memberships, dependent: :destroy
  has_many :members, through: :cohort_memberships, source: :user
  has_many :chat_messages, dependent: :destroy
  has_one_attached :header_image

  validates :name, presence: true
  validate :acceptable_header_image

  def member?(user)
    cohort_memberships.exists?(user_id: user.id)
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
