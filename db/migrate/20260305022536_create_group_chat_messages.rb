class CreateGroupChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :group_chat_messages do |t|
      t.text :body, null: false
      t.integer :group_id, null: false
      t.integer :user_id, null: false
      t.boolean :system_message, default: false, null: false

      t.timestamps
    end

    add_index :group_chat_messages, [ :group_id, :created_at ]
    add_index :group_chat_messages, :group_id
    add_index :group_chat_messages, :user_id
    add_foreign_key :group_chat_messages, :groups
    add_foreign_key :group_chat_messages, :users
  end
end
