class CreateCohortMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :cohort_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cohort, null: false, foreign_key: true
      t.datetime :joined_at, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    add_index :cohort_memberships, [ :user_id, :cohort_id ], unique: true
  end
end
