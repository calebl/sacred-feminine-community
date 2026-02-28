class CreateChatMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_messages do |t|
      t.references :cohort, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end

    add_index :chat_messages, [ :cohort_id, :created_at ]
  end
end
