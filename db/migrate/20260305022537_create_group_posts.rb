class CreateGroupPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :group_posts do |t|
      t.text :body
      t.integer :group_id, null: false
      t.integer :user_id, null: false
      t.boolean :draft, default: false, null: false
      t.boolean :pinned, default: false, null: false

      t.timestamps
    end

    add_index :group_posts, [ :group_id, :pinned, :created_at ], name: "index_group_posts_on_group_pinned_created"
    add_index :group_posts, [ :group_id, :user_id, :draft ], name: "index_group_posts_on_group_user_draft"
    add_index :group_posts, :group_id
    add_index :group_posts, :user_id
    add_foreign_key :group_posts, :groups
    add_foreign_key :group_posts, :users
  end
end
