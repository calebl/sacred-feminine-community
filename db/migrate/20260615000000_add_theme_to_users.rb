class AddThemeToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :theme, :integer, default: 0, null: false
  end
end
