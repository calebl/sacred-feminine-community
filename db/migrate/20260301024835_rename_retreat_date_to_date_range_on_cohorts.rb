class RenameRetreatDateToDateRangeOnCohorts < ActiveRecord::Migration[8.1]
  def change
    rename_column :cohorts, :retreat_date, :retreat_start_date
    add_column :cohorts, :retreat_end_date, :date
  end
end
