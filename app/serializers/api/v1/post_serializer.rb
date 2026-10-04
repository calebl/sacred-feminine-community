module Api
  module V1
    # One shape for every kind of post. Phase 1 serves only feed posts; cohort
    # and group posts will reuse it with their own `kind`.
    class PostSerializer < ContentSerializer
      include Rails.application.routes.url_helpers

      KINDS = { "FeedPost" => "feed" }.freeze

      def initialize(record, viewer:, include_comments: false)
        super(record, viewer: viewer)
        @include_comments = include_comments
      end

      def as_json(*)
        json = {
          id: record.id,
          kind: KINDS.fetch(record.class.name),
          body: body,
          mentions: mentions,
          author: author,
          pinned: record.pinned,
          comment_count: visible_comments.size,
          photos: photos,
          reactions: reactions,
          can_edit: policy.update?,
          can_delete: policy.destroy?,
          created_at: record.created_at,
          updated_at: record.updated_at
        }
        json[:comments] = comment_tree if @include_comments
        json
      end

      private

      def visible_comments
        @visible_comments ||= record.visible_comments(viewer)
      end

      def comment_tree
        visible_comments.select { |comment| comment.parent_id.nil? }.sort_by(&:created_at)
          .map { |comment| CommentSerializer.new(comment, viewer: viewer).as_json }
      end

      def photos
        record.photos.map do |photo|
          { id: photo.id, content_type: photo.content_type, path: rails_blob_path(photo, only_path: true) }
        end
      end
    end
  end
end
