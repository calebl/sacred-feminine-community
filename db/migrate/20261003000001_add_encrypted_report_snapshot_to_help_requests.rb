class AddEncryptedReportSnapshotToHelpRequests < ActiveRecord::Migration[8.2]
  def change
    add_column :help_requests, :reported_snapshot, :text
    add_index :help_requests,
      [ :user_id, :reportable_type, :reportable_id ],
      unique: true,
      where: "reportable_type IS NOT NULL AND status = 0",
      name: "index_help_requests_on_open_report"
  end
end
