class RemoveDraftFromPostsAndGroupPosts < ActiveRecord::Migration[8.1]
  def up
    Post.where(draft: true).delete_all
    GroupPost.where(draft: true).delete_all

    remove_index :posts, name: :index_posts_on_cohort_user_draft
    remove_column :posts, :draft

    remove_index :group_posts, name: :index_group_posts_on_group_user_draft
    remove_column :group_posts, :draft
  end

  def down
    add_column :posts, :draft, :boolean, default: false, null: false
    add_index :posts, [ :cohort_id, :user_id, :draft ], name: :index_posts_on_cohort_user_draft

    add_column :group_posts, :draft, :boolean, default: false, null: false
    add_index :group_posts, [ :group_id, :user_id, :draft ], name: :index_group_posts_on_group_user_draft
  end
end
