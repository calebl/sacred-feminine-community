class AddDmPrivacyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :dm_privacy, :integer, default: 1, null: false
  end
end
