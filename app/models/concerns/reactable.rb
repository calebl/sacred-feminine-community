module Reactable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :reactable, dependent: :destroy
  end

  def grouped_reactions
    reactions.group(:emoji).count
  end

  def reaction_by(user)
    reactions.find_by(user: user)
  end
end
