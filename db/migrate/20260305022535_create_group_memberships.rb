class CreateGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :group_memberships do |t|
      t.integer :user_id, null: false
      t.integer :group_id, null: false
      t.datetime :joined_at, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :last_read_at
      t.datetime :posts_last_read_at

      t.timestamps
    end

    add_index :group_memberships, :group_id
    add_index :group_memberships, :user_id
    add_index :group_memberships, [ :user_id, :group_id ], unique: true
    add_foreign_key :group_memberships, :users
    add_foreign_key :group_memberships, :groups
  end
end
