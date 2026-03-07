class AddFieldsToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :event_type, :string
    add_column :notifications, :notifiable_type, :string
    add_column :notifications, :notifiable_id, :integer
    add_column :notifications, :group_key, :string

    reversible do |dir|
      dir.up { Notification.update_all(event_type: "new_member") }
    end

    change_column_null :notifications, :event_type, false

    add_index :notifications, [ :user_id, :read_at ]
    add_index :notifications, [ :user_id, :created_at ]
    add_index :notifications, [ :notifiable_type, :notifiable_id ]
    add_index :notifications, [ :user_id, :group_key ]
  end
end
