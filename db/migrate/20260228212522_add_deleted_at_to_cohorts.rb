class AddDeletedAtToCohorts < ActiveRecord::Migration[8.1]
  def change
    add_column :cohorts, :discarded_at, :datetime
    add_index :cohorts, :discarded_at
  end
end
