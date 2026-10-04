class PrivacyPoliciesController < ApplicationController
  def show
    authorize :privacy_policy
  end
end
