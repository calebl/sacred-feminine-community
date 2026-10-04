module Api
  module V1
    # The community feed, newest first. Lists page with a cursor: pass the
    # `next_cursor` from one page as `before` to get the next, until it is null.
    # Pinned posts are not lifted to the top here; each post carries `pinned`
    # so the app can show them as it likes.
    class FeedPostsController < BaseController
      DEFAULT_LIMIT = 20
      MAX_LIMIT = 50

      after_action :verify_policy_scoped

      def index
        authorize FeedPost
        posts = policy_scope(FeedPost).order(id: :desc)
        posts = posts.where(id: ...params[:before].to_i) if params[:before].present?
        page = posts.limit(limit + 1)
          .includes(:reactions, { photos_attachments: :blob },
                    user: { avatar_attachment: :blob }, feed_post_comments: :user)
          .to_a
        next_cursor = page.size > limit ? page[limit - 1].id : nil

        render json: {
          posts: page.first(limit).map { |post| PostSerializer.new(post, viewer: current_user).as_json },
          next_cursor: next_cursor
        }
      end

      def show
        post = policy_scope(FeedPost).find(params[:id])
        authorize post
        post = FeedPost.includes(:reactions, { photos_attachments: :blob },
                                 feed_post_comments: [ :user, :reactions, { replies: [ :user, :reactions ] } ])
                       .find(post.id)
        render json: { post: PostSerializer.new(post, viewer: current_user, include_comments: true).as_json }
      end

      private

      def limit
        @limit ||= params[:limit].present? ? params[:limit].to_i.clamp(1, MAX_LIMIT) : DEFAULT_LIMIT
      end
    end
  end
end
