class CreateFeedPostReads < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_post_reads do |t|
      t.references :feed_post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :last_read_at

      t.timestamps
    end

    add_index :feed_post_reads, [ :user_id, :feed_post_id ], unique: true, name: "index_feed_post_reads_on_user_and_post"
  end
end
