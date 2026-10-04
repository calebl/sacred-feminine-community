class AddReportableToHelpRequests < ActiveRecord::Migration[8.2]
  def change
    add_reference :help_requests, :reportable, polymorphic: true, null: true
  end
end
