class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    authorize @user, :show_profile?
    @cohorts = @user.cohorts.includes(:members).order(retreat_start_date: :desc)
  end

  def edit
    authorize @user, :edit_profile?
  end

  def update
    authorize @user, :update_profile?

    if @user.update(profile_params)
      @user.avatar.purge if params[:user][:remove_avatar] == "1"
      redirect_to profile_path(@user), notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.kept.find(params[:id])
  end

  def profile_params
    params.require(:user).permit(:name, :bio, :city, :state, :country, :show_on_map, :avatar, :dm_privacy, :dm_notifications)
  end
end
