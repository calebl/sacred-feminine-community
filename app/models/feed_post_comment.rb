class FeedPostComment < ApplicationRecord
  include Mentionable

  belongs_to :feed_post
  belongs_to :user
  belongs_to :parent, class_name: "FeedPostComment", optional: true

  has_many :replies, class_name: "FeedPostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }

  scope :top_level, -> { where(parent_id: nil) }
end
