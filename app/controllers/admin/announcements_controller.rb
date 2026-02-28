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
        redirect_to admin_announcements_path, notice: "Announcement created."
      else
        render :new, status: :unprocessable_entity
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

    def policy_scope_required?
      action_name == "index"
    end
  end
end
