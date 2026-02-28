module Api
  class MapPinsController < ApplicationController
    before_action :authenticate_user!
    after_action :verify_policy_scoped

    def index
      skip_authorization
      users = policy_scope(User).where(show_on_map: true)
                   .where.not(latitude: nil)
                   .where.not(longitude: nil)
                   .select(:id, :name, :city, :country, :latitude, :longitude)

      render json: users.map { |u|
        {
          id: u.id,
          name: u.name,
          city: u.city,
          country: u.country,
          lat: u.latitude.to_f,
          lng: u.longitude.to_f
        }
      }
    end
  end
end
