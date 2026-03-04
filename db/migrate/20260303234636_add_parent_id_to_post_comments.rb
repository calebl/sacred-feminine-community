class AddParentIdToPostComments < ActiveRecord::Migration[8.1]
  def change
    add_column :post_comments, :parent_id, :integer
    add_index :post_comments, :parent_id
    add_foreign_key :post_comments, :post_comments, column: :parent_id
  end
end
