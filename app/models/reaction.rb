class Reaction < ApplicationRecord
  ALLOWED_EMOJIS = %w[👍 ❤️ 😂 😮 🙏 🔥].freeze

  belongs_to :reactable, polymorphic: true
  belongs_to :user

  validates :emoji, presence: true, inclusion: { in: ALLOWED_EMOJIS }
  validates :user_id, uniqueness: { scope: [ :reactable_type, :reactable_id ] }
end
