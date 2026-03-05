class Faq < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :faqs

  validates :question, presence: true
  validates :answer, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :created_at) }
end
