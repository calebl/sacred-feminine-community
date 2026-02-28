class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    skip_authorization
  end
end
