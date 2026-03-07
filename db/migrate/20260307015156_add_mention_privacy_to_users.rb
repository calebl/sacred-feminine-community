class AddMentionPrivacyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mention_privacy, :integer, default: 2, null: false
  end
end
