class Group < ApplicationRecord
  include Discard::Model

  audited
  has_associated_audits

  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :created_groups
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :group_posts, dependent: :destroy
  has_one_attached :header_image

  validates :name, presence: true
  validate :acceptable_header_image

  after_create :add_creator_as_member

  def member?(user)
    group_memberships.exists?(user_id: user.id)
  end

  def creator?(user)
    created_by_id == user.id
  end

  def unread_post_count(user)
    membership = group_memberships.find_by(user: user)
    return 0 unless membership

    new_posts = group_posts.where.not(user: user)
    if membership.posts_last_read_at
      new_posts.where("group_posts.created_at > ?", membership.posts_last_read_at).count
    else
      new_posts.count
    end
  end

  private

  def add_creator_as_member
    group_memberships.create!(user: creator)
  end

  def acceptable_header_image
    return unless header_image.attached?
    unless header_image.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:header_image, "must be a JPEG, PNG, GIF, or WebP")
    end
    if header_image.blob.byte_size > 10.megabytes
      errors.add(:header_image, "must be less than 10MB")
    end
  end
end
