class AddSystemMessageToChatMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_messages, :system_message, :boolean, default: false, null: false
  end
end
