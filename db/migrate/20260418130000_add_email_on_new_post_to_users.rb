class AddEmailOnNewPostToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_on_new_post, :boolean, default: true, null: false
  end
end
