class CreateFeedPostComments < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_post_comments do |t|
      t.text :body, null: false
      t.references :feed_post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :feed_post_comments }

      t.timestamps
    end
  end
end
