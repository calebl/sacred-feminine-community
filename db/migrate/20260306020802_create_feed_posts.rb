class CreateFeedPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_posts do |t|
      t.text :body
      t.integer :user_id, null: false
      t.boolean :pinned, default: false, null: false

      t.timestamps
    end

    add_index :feed_posts, [ :pinned, :created_at ], name: "index_feed_posts_on_pinned_created"
    add_index :feed_posts, :user_id
    add_foreign_key :feed_posts, :users
  end
end
