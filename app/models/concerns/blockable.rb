# Content authored by a user (posts, comments) that should be hidden from a
# viewer when a block exists between them, or when a cohort gender preference on
# either side excludes the other. Both rules are mutual for visibility: neither
# party sees the other's content. Keeps the rule in one place instead of
# repeating it in every controller and view that lists this content — see
# User#hidden_content_user_ids for what it covers.
module Blockable
  extend ActiveSupport::Concern

  included do
    scope :visible_to, ->(user) { where.not(user_id: user.hidden_content_user_ids) }
  end

  class_methods do
    # In-memory counterpart to `visible_to`, for associations that are already
    # loaded. Post lists preload their comments and replies with `includes`;
    # `visible_to` would discard that preload and issue a query per parent
    # record, so they reject in Ruby against the same set of ids instead.
    def reject_hidden_from(records, viewer)
      hidden_ids = viewer.hidden_content_user_ids
      # `persisted?` drops the unsaved record a page builds onto the association
      # to back its reply form (`post_comments.build`): it sits in the loaded
      # target but is nobody's content yet, and counting it would inflate every
      # reply count by one.
      records.select { |record| record.persisted? && !hidden_ids.include?(record.user_id) }
    end
  end
end
