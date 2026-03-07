class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :actor, null: true, foreign_key: { to_table: :users }
      t.string :event_type, null: false
      t.string :title
      t.string :body
      t.string :path
      t.string :notifiable_type
      t.integer :notifiable_id
      t.string :group_key
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, [ :user_id, :read_at ]
    add_index :notifications, [ :user_id, :created_at ]
    add_index :notifications, [ :notifiable_type, :notifiable_id ]
    add_index :notifications, [ :user_id, :group_key ]
  end
end
