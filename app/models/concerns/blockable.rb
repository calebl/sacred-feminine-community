# Content authored by a user (posts, comments) that should be hidden when a
# block exists between the author and the viewer. Blocking is mutual for
# visibility: neither party sees the other's content. Adds a `visible_to` scope
# so the rule lives in one place instead of being repeated in every controller
# that lists this content.
module Blockable
  extend ActiveSupport::Concern

  included do
    scope :visible_to, ->(user) { where.not(user_id: user.hidden_content_user_ids) }
  end
end
