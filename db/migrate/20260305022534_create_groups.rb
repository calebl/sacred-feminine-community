class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.text :description
      t.integer :created_by_id, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :groups, :created_by_id
    add_index :groups, :discarded_at
    add_foreign_key :groups, :users, column: :created_by_id
  end
end
