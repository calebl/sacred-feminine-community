class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.datetime :published_at
      t.boolean :active, default: false, null: false
      t.integer :created_by_id, null: false

      t.timestamps
    end

    add_foreign_key :announcements, :users, column: :created_by_id
    add_index :announcements, :active
    add_index :announcements, :created_by_id
  end
end
