module Reactable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :reactable, dependent: :destroy
  end

  def grouped_reactions
    reactions.each_with_object(Hash.new(0)) { |r, h| h[r.emoji] += 1 }
  end

  def reactor_names_by_emoji
    reactions.includes(:user).each_with_object(Hash.new { |h, k| h[k] = [] }) do |r, h|
      h[r.emoji] << r.user.name
    end
  end

  def reaction_by(user)
    reactions.detect { |r| r.user_id == user.id }
  end
end
