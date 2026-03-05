class CreateMentions < ActiveRecord::Migration[8.1]
  def change
    create_table :mentions do |t|
      t.references :mentionable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.references :mentioner, null: false, foreign_key: { to_table: :users }
      t.datetime :read_at
      t.timestamps
    end

    add_index :mentions, [ :mentionable_type, :mentionable_id, :user_id ],
              unique: true, name: "index_mentions_on_mentionable_and_user"
    add_index :mentions, [ :user_id, :read_at ]
  end
end
