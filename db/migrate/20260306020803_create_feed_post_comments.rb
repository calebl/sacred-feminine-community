class CreateFeedPostComments < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_post_comments do |t|
      t.text :body, null: false
      t.integer :feed_post_id, null: false
      t.integer :user_id, null: false
      t.integer :parent_id

      t.timestamps
    end

    add_index :feed_post_comments, :feed_post_id
    add_index :feed_post_comments, :user_id
    add_index :feed_post_comments, :parent_id
    add_foreign_key :feed_post_comments, :feed_posts
    add_foreign_key :feed_post_comments, :users
    add_foreign_key :feed_post_comments, :feed_post_comments, column: :parent_id
  end
end
