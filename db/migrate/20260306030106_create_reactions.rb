class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions do |t|
      t.references :reactable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.string :emoji, null: false

      t.timestamps
    end

    add_index :reactions, [ :reactable_type, :reactable_id, :user_id ],
              unique: true, name: "index_reactions_on_reactable_and_user"
    add_index :reactions, [ :reactable_type, :reactable_id, :emoji ],
              name: "index_reactions_on_reactable_and_emoji"
  end
end
