class PostComment < ApplicationRecord
  include Mentionable

  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: "PostComment", optional: true

  has_many :replies, class_name: "PostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  scope :top_level, -> { where(parent_id: nil) }
end
