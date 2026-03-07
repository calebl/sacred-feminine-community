class CreateReleases < ActiveRecord::Migration[8.1]
  def change
    create_table :releases do |t|
      t.string :version, null: false
      t.string :commit_sha, null: false
      t.text :changelog, null: false
      t.datetime :deployed_at, null: false

      t.timestamps
    end

    add_index :releases, :version, unique: true
    add_index :releases, :deployed_at
  end
end
