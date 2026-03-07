module Admin
  class FeaturesController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :admin_dashboard
      features_path = Rails.root.join("FEATURES.md")
      markdown = File.read(features_path)
      renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
      @features_html = Redcarpet::Markdown.new(renderer).render(markdown).html_safe
    end
  end
end
