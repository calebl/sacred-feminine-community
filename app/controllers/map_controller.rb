class MapController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization
  end
end
