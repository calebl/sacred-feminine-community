class UserBlock < ApplicationRecord
  belongs_to :blocker, class_name: "User", inverse_of: :user_blocks
  belongs_to :blocked, class_name: "User", inverse_of: :blocked_by_blocks

  validates :blocked_id, uniqueness: { scope: :blocker_id }
  validate :cannot_block_self

  private

  def cannot_block_self
    errors.add(:blocked, "cannot block yourself") if blocker_id == blocked_id
  end
end
