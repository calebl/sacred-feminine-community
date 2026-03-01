require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires title" do
    post = Post.new(cohort: cohorts(:kabul_retreat), user: users(:attendee))
    post.body = "Some content"
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "rejects title over 200 characters" do
    post = Post.new(title: "x" * 201, cohort: cohorts(:kabul_retreat), user: users(:attendee))
    post.body = "Content"
    assert_not post.valid?
  end

  test "requires body" do
    post = Post.new(title: "Test", cohort: cohorts(:kabul_retreat), user: users(:attendee))
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "valid with all attributes" do
    post = Post.new(title: "Test Post", cohort: cohorts(:kabul_retreat), user: users(:attendee))
    post.body = "Hello world"
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

  test "draft can save without title or body" do
    post = Post.new(cohort: cohorts(:bali_retreat), user: users(:admin), draft: true)
    assert post.valid?
    assert post.save
  end

  test "only one draft per cohort per user" do
    duplicate = Post.new(cohort: cohorts(:kabul_retreat), user: users(:attendee), draft: true)
    assert_not duplicate.valid?
    assert duplicate.errors[:base].any?
  end

  test "published scope excludes drafts" do
    published = cohorts(:kabul_retreat).posts.published
    assert_not_includes published, posts(:attendee_draft)
    assert_includes published, posts(:attendee_post)
  end

  test "drafts scope returns only drafts" do
    drafts = cohorts(:kabul_retreat).posts.drafts
    assert_includes drafts, posts(:attendee_draft)
    assert_not_includes drafts, posts(:attendee_post)
  end
end
