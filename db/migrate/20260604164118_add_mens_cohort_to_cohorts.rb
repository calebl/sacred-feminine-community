class AddMensCohortToCohorts < ActiveRecord::Migration[8.2]
  def change
    add_column :cohorts, :mens_cohort, :boolean, default: false, null: false
  end
end
