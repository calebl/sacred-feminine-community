class CreateFeedPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_posts do |t|
      t.text :body, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :pinned, default: false, null: false

      t.timestamps
    end

    add_index :feed_posts, [ :pinned, :created_at ], name: "index_feed_posts_on_pinned_created"
  end
end
