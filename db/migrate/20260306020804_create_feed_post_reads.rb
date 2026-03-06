class CreateFeedPostReads < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_post_reads do |t|
      t.integer :feed_post_id, null: false
      t.integer :user_id, null: false
      t.datetime :last_read_at

      t.timestamps
    end

    add_index :feed_post_reads, :feed_post_id
    add_index :feed_post_reads, :user_id
    add_index :feed_post_reads, [ :user_id, :feed_post_id ], unique: true, name: "index_feed_post_reads_on_user_and_post"
    add_foreign_key :feed_post_reads, :feed_posts
    add_foreign_key :feed_post_reads, :users
  end
end
