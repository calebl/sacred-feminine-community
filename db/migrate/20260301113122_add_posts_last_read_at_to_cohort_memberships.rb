class AddPostsLastReadAtToCohortMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :cohort_memberships, :posts_last_read_at, :datetime
  end
end
