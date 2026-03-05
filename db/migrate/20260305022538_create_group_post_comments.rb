class CreateGroupPostComments < ActiveRecord::Migration[8.1]
  def change
    create_table :group_post_comments do |t|
      t.text :body, null: false
      t.integer :group_post_id, null: false
      t.integer :user_id, null: false
      t.integer :parent_id

      t.timestamps
    end

    add_index :group_post_comments, :group_post_id
    add_index :group_post_comments, :user_id
    add_index :group_post_comments, :parent_id
    add_foreign_key :group_post_comments, :group_posts
    add_foreign_key :group_post_comments, :users
    add_foreign_key :group_post_comments, :group_post_comments, column: :parent_id
  end
end
