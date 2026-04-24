class CreateBulkInvitations < ActiveRecord::Migration[8.2]
  def change
    create_table :bulk_invitations do |t|
      t.references :cohort, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.text :message
      t.integer :sent_count, default: 0, null: false
      t.integer :skipped_count, default: 0, null: false
      t.integer :failed_count, default: 0, null: false

      t.timestamps
    end
  end
end
