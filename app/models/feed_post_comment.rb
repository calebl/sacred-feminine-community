class FeedPostComment < ApplicationRecord
  include Mentionable

  belongs_to :feed_post
  belongs_to :user
  belongs_to :parent, class_name: "FeedPostComment", optional: true

  has_many :replies, class_name: "FeedPostComment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }
  validate :parent_belongs_to_same_post, if: :parent_id?

  scope :top_level, -> { where(parent_id: nil) }

  private

  def parent_belongs_to_same_post
    if parent && parent.feed_post_id != feed_post_id
      errors.add(:parent_id, "must belong to the same post")
    end
  end
end
