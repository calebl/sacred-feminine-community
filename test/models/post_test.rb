require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires body" do
    post = Post.new(cohort: cohorts(:kabul_retreat), user: users(:attendee))
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "valid with body" do
    post = Post.new(cohort: cohorts(:kabul_retreat), user: users(:attendee), body: "Hello world")
    assert post.valid?
  end

  test "pinned_first scope orders pinned posts first" do
    posts_list = cohorts(:kabul_retreat).posts.pinned_first.to_a
    pinned_indices = posts_list.each_index.select { |i| posts_list[i].pinned? }
    unpinned_indices = posts_list.each_index.reject { |i| posts_list[i].pinned? }

    if pinned_indices.any? && unpinned_indices.any?
      assert pinned_indices.max < unpinned_indices.min
    end
  end

  test "destroying post destroys comments" do
    post = posts(:attendee_post)
    assert post.post_comments.any?
    assert_difference "PostComment.count", -post.post_comments.count do
      post.destroy
    end
  end
end
