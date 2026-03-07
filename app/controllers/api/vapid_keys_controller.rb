class Api::VapidKeysController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :vapid_key

    render json: { public_key: Rails.application.config.vapid[:public_key] }
  end
end
