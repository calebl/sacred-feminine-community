module Api
  module V1
    # Shared pieces of the post and comment shapes. Everything here is filtered
    # through the viewer's hidden_content_user_ids, so the app never has to
    # repeat the block and cohort gender rules.
    class ContentSerializer
      def initialize(record, viewer:)
        @record = record
        @viewer = viewer
      end

      private

      attr_reader :record, :viewer

      # The body with mention markup reduced to "@Name", matching what the
      # website shows as text.
      def body
        record.body.to_s.gsub(Mentionable::MENTION_PATTERN) { "@#{$1}" }
      end

      # Mentions the app may link to a profile. Mentions of hidden members stay
      # plain text in the body, as they do on the website.
      def mentions
        record.body.to_s.scan(Mentionable::MENTION_PATTERN)
          .map { |name, id| { user_id: id.to_i, name: name } }
          .uniq { |mention| mention[:user_id] }
          .reject { |mention| hidden_ids.include?(mention[:user_id]) }
      end

      def reactions
        visible = record.reactions.reject { |reaction| hidden_ids.include?(reaction.user_id) }
        visible.group_by(&:emoji).map do |emoji, group|
          { emoji: emoji, count: group.size, reacted_by_me: group.any? { |reaction| reaction.user_id == viewer.id } }
        end
      end

      def author
        UserSerializer.new(record.user).as_json
      end

      def hidden_ids
        viewer.hidden_content_user_ids
      end

      def policy
        @policy ||= Pundit.policy!(viewer, record)
      end
    end
  end
end
