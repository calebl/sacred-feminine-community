class BulkInvitation < ApplicationRecord
  belongs_to :cohort
  belongs_to :invited_by, class_name: "User"

  has_many :users, dependent: :nullify

  validates :cohort, presence: true
  validates :invited_by, presence: true
end
