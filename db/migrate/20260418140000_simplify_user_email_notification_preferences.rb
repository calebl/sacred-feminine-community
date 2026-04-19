class SimplifyUserEmailNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_notifications_enabled, :boolean, default: true, null: false
    remove_column :users, :email_on_new_member, :boolean, default: true, null: false
    remove_column :users, :email_on_help_request, :boolean, default: true, null: false
    remove_column :users, :email_on_help_request_reply, :boolean, default: true, null: false
  end
end
