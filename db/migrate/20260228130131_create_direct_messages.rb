class CreateDirectMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :direct_messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false

      t.timestamps
    end

    add_index :direct_messages, [ :conversation_id, :created_at ]
  end
end
