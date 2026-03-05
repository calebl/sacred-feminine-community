class RemoveTitleFromPosts < ActiveRecord::Migration[8.1]
  def change
    remove_column :posts, :title, :string
  end
end
