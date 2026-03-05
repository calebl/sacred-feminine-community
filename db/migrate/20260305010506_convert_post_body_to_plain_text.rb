class ConvertPostBodyToPlainText < ActiveRecord::Migration[8.1]
  def up
    add_column :posts, :body, :text

    # Migrate existing Action Text content to the new column
    execute <<~SQL
      UPDATE posts
      SET body = (
        SELECT action_text_rich_texts.body
        FROM action_text_rich_texts
        WHERE action_text_rich_texts.record_type = 'Post'
          AND action_text_rich_texts.record_id = posts.id
          AND action_text_rich_texts.name = 'body'
      )
    SQL

    # Clean up Action Text records for posts
    execute <<~SQL
      DELETE FROM action_text_rich_texts
      WHERE record_type = 'Post' AND name = 'body'
    SQL
  end

  def down
    # Move body back to Action Text
    execute <<~SQL
      INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
      SELECT 'body', posts.body, 'Post', posts.id, posts.created_at, posts.updated_at
      FROM posts
      WHERE posts.body IS NOT NULL
    SQL

    remove_column :posts, :body
  end
end
