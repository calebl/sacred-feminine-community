class AddCohortGenderPrivacyToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :cohort_gender_privacy, :integer, default: 0, null: false
    add_index :users, :cohort_gender_privacy
  end
end
