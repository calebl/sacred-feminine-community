class CreateHelpRequests < ActiveRecord::Migration[8.2]
  def change
    create_table :help_requests do |t|
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :status, default: 0, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :help_requests, [ :status, :created_at ]
  end
end
