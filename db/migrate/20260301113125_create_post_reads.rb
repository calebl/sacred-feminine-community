class CreatePostReads < ActiveRecord::Migration[8.1]
  def change
    create_table :post_reads do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :last_read_at

      t.timestamps
    end

    add_index :post_reads, [ :user_id, :post_id ], unique: true
  end
end
