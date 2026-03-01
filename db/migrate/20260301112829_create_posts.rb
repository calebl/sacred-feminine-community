class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.references :cohort, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :pinned, default: false, null: false

      t.timestamps
    end

    add_index :posts, [ :cohort_id, :pinned, :created_at ], name: "index_posts_on_cohort_pinned_created"
  end
end
