class DropAnnouncementsAndChatMessages < ActiveRecord::Migration[8.1]
  def up
    drop_table :announcements, if_exists: true
    drop_table :chat_messages, if_exists: true
    drop_table :group_chat_messages, if_exists: true
  end

  def down
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.datetime :published_at
      t.boolean :active, default: false, null: false
      t.bigint :created_by_id
      t.timestamps
      t.index :active
      t.index :created_by_id
    end
    add_foreign_key :announcements, :users, column: :created_by_id

    create_table :chat_messages do |t|
      t.references :cohort, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :system_message, default: false, null: false
      t.timestamps
      t.index [ :cohort_id, :created_at ]
    end

    create_table :group_chat_messages do |t|
      t.text :body, null: false
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :system_message, default: false, null: false
      t.timestamps
      t.index [ :group_id, :created_at ]
    end
  end
end
