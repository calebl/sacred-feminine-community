class AddDraftToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :draft, :boolean, default: false, null: false
    change_column_null :posts, :title, true
    add_index :posts, [ :cohort_id, :user_id, :draft ], name: "index_posts_on_cohort_user_draft"
  end
end
