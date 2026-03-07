class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :actor, null: true, foreign_key: { to_table: :users }
      t.string :title
      t.string :body
      t.string :path
      t.datetime :read_at

      t.timestamps
    end
  end
end
