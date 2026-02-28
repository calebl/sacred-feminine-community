class Announcement < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :announcements

  validates :title, presence: true
  validates :body, presence: true

  scope :active, -> { where(active: true) }
  scope :live, -> { active.where("published_at <= ?", Time.current) }
  scope :current, -> { live.order(published_at: :desc).limit(1) }

  before_save :deactivate_others, if: :active?
  before_save :set_published_at, if: -> { active? && published_at.blank? }

  def scheduled?
    active? && published_at.present? && published_at > Time.current
  end

  private

  def deactivate_others
    Announcement.where(active: true).where.not(id: id).update_all(active: false)
  end

  def set_published_at
    self.published_at = Time.current
  end
end
