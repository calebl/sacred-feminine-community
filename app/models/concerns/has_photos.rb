module HasPhotos
  extend ActiveSupport::Concern

  included do
    has_many_attached :photos
    validate :acceptable_photos
  end

  PHOTO_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  MAX_PHOTO_SIZE = 10.megabytes
  MAX_PHOTOS = 10

  private

  def acceptable_photos
    return unless photos.attached?

    if photos.count > MAX_PHOTOS
      errors.add(:photos, "cannot exceed #{MAX_PHOTOS} images")
    end

    photos.each do |photo|
      unless photo.blob.content_type.in?(PHOTO_CONTENT_TYPES)
        errors.add(:photos, "must be JPEG, PNG, GIF, or WebP")
        break
      end
      if photo.blob.byte_size > MAX_PHOTO_SIZE
        errors.add(:photos, "must each be less than 10MB")
        break
      end
    end
  end
end
