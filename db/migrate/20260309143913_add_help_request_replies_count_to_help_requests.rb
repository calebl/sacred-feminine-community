class AddHelpRequestRepliesCountToHelpRequests < ActiveRecord::Migration[8.2]
  def change
    add_column :help_requests, :help_request_replies_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        HelpRequest.find_each do |help_request|
          HelpRequest.reset_counters(help_request.id, :help_request_replies)
        end
      end
    end
  end
end
