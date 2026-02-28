class CohortMembership < ApplicationRecord
  belongs_to :user
  belongs_to :cohort

  validates :user_id, uniqueness: { scope: :cohort_id, message: "is already a member" }
end
