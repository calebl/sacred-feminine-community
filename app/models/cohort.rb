class Cohort < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :created_cohorts
  has_many :cohort_memberships, dependent: :destroy
  has_many :members, through: :cohort_memberships, source: :user
  has_many :chat_messages, dependent: :destroy

  validates :name, presence: true

  def member?(user)
    cohort_memberships.exists?(user_id: user.id)
  end
end
