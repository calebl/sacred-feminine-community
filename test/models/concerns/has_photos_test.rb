require "test_helper"

class HasPhotosTest < ActiveSupport::TestCase
  test "valid with photos attached" do
    post = FeedPost.new(user: users(:attendee), body: "Photo post")
    post.photos.attach(io: StringIO.new("fake image data"), filename: "test.jpg", content_type: "image/jpeg")
    assert post.valid?
  end

  test "rejects non-image photo content types" do
    post = FeedPost.new(user: users(:attendee), body: "Bad photo")
    post.photos.attach(io: StringIO.new("not an image"), filename: "test.txt", content_type: "text/plain")
    assert_not post.valid?
    assert_includes post.errors[:photos], "must be JPEG, PNG, GIF, or WebP"
  end

  test "rejects photos over 10MB" do
    post = FeedPost.new(user: users(:attendee), body: "Big photo")
    large_data = "x" * (11 * 1024 * 1024)
    post.photos.attach(io: StringIO.new(large_data), filename: "huge.jpg", content_type: "image/jpeg")
    assert_not post.valid?
    assert_includes post.errors[:photos], "must each be less than 10MB"
  end

  test "rejects more than 10 photos" do
    post = FeedPost.new(user: users(:attendee), body: "Many photos")
    11.times do |i|
      post.photos.attach(io: StringIO.new("fake"), filename: "photo_#{i}.jpg", content_type: "image/jpeg")
    end
    assert_not post.valid?
    assert_includes post.errors[:photos], "cannot exceed 10 images"
  end
end
