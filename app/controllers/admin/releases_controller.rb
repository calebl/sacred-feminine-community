module Admin
  class ReleasesController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize Release
      @releases = Release.recent
    end
  end
end
