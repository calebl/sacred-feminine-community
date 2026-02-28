class GeocodeUserJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.geocode
    user.save!
  end
end
