class CreateCohorts < ActiveRecord::Migration[8.1]
  def change
    create_table :cohorts do |t|
      t.string :name, null: false
      t.text :description
      t.string :retreat_location
      t.date :retreat_date
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
