class Mention < ApplicationRecord
  belongs_to :mentionable, polymorphic: true
  belongs_to :user
  belongs_to :mentioner, class_name: "User"

  scope :unread, -> { where(read_at: nil) }

  validates :user_id, uniqueness: { scope: [ :mentionable_type, :mentionable_id ] }

  def read!
    update!(read_at: Time.current) unless read_at?
  end
end
