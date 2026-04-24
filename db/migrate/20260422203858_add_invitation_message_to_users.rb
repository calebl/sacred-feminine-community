class AddInvitationMessageToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :invitation_message, :text
  end
end
