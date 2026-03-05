class GroupMembership < ApplicationRecord
  audited associated_with: :group

  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id, message: "is already a member" }
end
