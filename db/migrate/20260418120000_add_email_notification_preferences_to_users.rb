class AddEmailNotificationPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_on_mention, :boolean, default: true, null: false
    add_column :users, :email_on_direct_message, :boolean, default: true, null: false
    add_column :users, :email_on_new_comment, :boolean, default: true, null: false
    add_column :users, :email_on_new_member, :boolean, default: true, null: false
    add_column :users, :email_on_help_request, :boolean, default: true, null: false
    add_column :users, :email_on_help_request_reply, :boolean, default: true, null: false
  end
end
