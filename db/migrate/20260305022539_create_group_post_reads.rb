class CreateGroupPostReads < ActiveRecord::Migration[8.1]
  def change
    create_table :group_post_reads do |t|
      t.integer :group_post_id, null: false
      t.integer :user_id, null: false
      t.datetime :last_read_at

      t.timestamps
    end

    add_index :group_post_reads, :group_post_id
    add_index :group_post_reads, :user_id
    add_index :group_post_reads, [ :user_id, :group_post_id ], unique: true, name: "index_group_post_reads_on_user_and_post"
    add_foreign_key :group_post_reads, :group_posts
    add_foreign_key :group_post_reads, :users
  end
end
