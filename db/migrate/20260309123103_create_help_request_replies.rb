class CreateHelpRequestReplies < ActiveRecord::Migration[8.2]
  def change
    create_table :help_request_replies do |t|
      t.text :body, null: false
      t.references :help_request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
