class CreateFaqs < ActiveRecord::Migration[8.1]
  def change
    create_table :faqs do |t|
      t.string :question, null: false
      t.text :answer, null: false
      t.integer :position, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.integer :created_by_id, null: false

      t.timestamps
    end

    add_foreign_key :faqs, :users, column: :created_by_id
    add_index :faqs, :active
    add_index :faqs, :created_by_id
  end
end
