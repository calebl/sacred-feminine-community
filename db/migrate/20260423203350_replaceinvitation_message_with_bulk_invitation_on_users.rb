class ReplaceinvitationMessageWithBulkInvitationOnUsers < ActiveRecord::Migration[8.2]
  def change
    add_reference :users, :bulk_invitation, null: true, foreign_key: true
    remove_column :users, :invitation_message, :text
  end
end
