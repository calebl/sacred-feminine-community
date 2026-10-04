module Api
  module V1
    # A comment and its visible replies, nested the way the website shows them.
    class CommentSerializer < ContentSerializer
      def as_json(*)
        {
          id: record.id,
          post_id: record.feed_post_id,
          parent_id: record.parent_id,
          body: body,
          mentions: mentions,
          author: author,
          reactions: reactions,
          can_delete: policy.destroy?,
          created_at: record.created_at,
          updated_at: record.updated_at,
          replies: record.visible_replies(viewer).map { |reply| CommentSerializer.new(reply, viewer: viewer).as_json }
        }
      end
    end
  end
end
