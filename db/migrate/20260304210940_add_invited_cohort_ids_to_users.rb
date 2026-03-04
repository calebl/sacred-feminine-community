class AddInvitedCohortIdsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :invited_cohort_ids, :text
  end
end
