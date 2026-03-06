class AddDmNotificationsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :dm_notifications, :boolean, default: true, null: false
  end
end
