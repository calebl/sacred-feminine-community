module Admin
  class AnnouncementsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_announcement, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize Announcement
      @announcements = policy_scope(Announcement).order(created_at: :desc)
    end

    def show
      authorize @announcement
    end

    def new
      @announcement = Announcement.new
      authorize @announcement
    end

    def create
      @announcement = Announcement.new(announcement_params)
      @announcement.creator = current_user
      authorize @announcement

      if @announcement.save
        redirect_to after_create_path, notice: "Announcement created."
      else
        if params[:source] == "dashboard"
          redirect_to authenticated_root_path, alert: @announcement.errors.full_messages.to_sentence
        else
          render :new, status: :unprocessable_entity
        end
      end
    end

    def edit
      authorize @announcement
    end

    def update
      authorize @announcement
      if @announcement.update(announcement_params)
        redirect_to admin_announcements_path, notice: "Announcement updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @announcement
      @announcement.destroy
      redirect_to admin_announcements_path, notice: "Announcement deleted."
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:title, :body, :active, :published_at)
    end

    def after_create_path
      params[:source] == "dashboard" ? authenticated_root_path : admin_announcements_path
    end

    def policy_scope_required?
      action_name == "index"
    end
  end
end
