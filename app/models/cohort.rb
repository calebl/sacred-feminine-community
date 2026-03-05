class Cohort < ApplicationRecord
  include Discard::Model

  audited
  has_associated_audits

  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :created_cohorts
  has_many :cohort_memberships
  has_many :members, through: :cohort_memberships, source: :user
  has_many :chat_messages
  has_many :posts, dependent: :destroy
  has_one_attached :header_image

  validates :name, presence: true
  validate :acceptable_header_image
  validate :end_date_after_start_date

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

  def unread_post_count(user)
    membership = cohort_memberships.find_by(user: user)
    return 0 unless membership

    new_posts = posts.where.not(user: user)
    if membership.posts_last_read_at
      new_posts.where("posts.created_at > ?", membership.posts_last_read_at).count
    else
      new_posts.count
    end
  end

  def formatted_date_range
    return nil unless retreat_start_date.present?
    return retreat_start_date.strftime("%b %-d, %Y") unless retreat_end_date.present?

    if retreat_start_date.month == retreat_end_date.month && retreat_start_date.year == retreat_end_date.year
      "#{retreat_start_date.strftime('%b %-d')} – #{retreat_end_date.strftime('%-d, %Y')}"
    elsif retreat_start_date.year != retreat_end_date.year
      "#{retreat_start_date.strftime('%b %-d, %Y')} – #{retreat_end_date.strftime('%b %-d, %Y')}"
    else
      "#{retreat_start_date.strftime('%b %-d')} – #{retreat_end_date.strftime('%b %-d, %Y')}"
    end
  end

  private

  def end_date_after_start_date
    return unless retreat_start_date.present? && retreat_end_date.present?
    if retreat_end_date < retreat_start_date
      errors.add(:retreat_end_date, "must be on or after the start date")
    end
  end

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
