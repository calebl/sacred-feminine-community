module Reactable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :reactable, dependent: :destroy
  end

  def grouped_reactions
    reactions.each_with_object(Hash.new(0)) { |r, h| h[r.emoji] += 1 }
  end

  def reaction_by(user)
    reactions.detect { |r| r.user_id == user.id }
  end
end
