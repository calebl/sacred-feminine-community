class CohortsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort, only: [ :show, :edit, :update, :destroy ]

  def index
    skip_authorization
    @cohorts = policy_scope(Cohort).includes(:members).with_attached_header_image.order(retreat_start_date: :desc)
  end

  def show
    authorize @cohort
    unless request.headers["Purpose"] == "prefetch"
      membership = @cohort.cohort_memberships.find_by(user: current_user)
      membership&.update(last_read_at: Time.current)
    end
    @members = @cohort.members.includes(:cohort_memberships).load
    @membership_ids = CohortMembership.where(cohort: @cohort, user_id: @members.map(&:id)).pluck(:user_id, :id).to_h
    @non_members = User.where.not(id: @members.map(&:id)).order(:name).pluck(:name, :id)
    @chat_messages = @cohort.chat_messages
                            .includes(:user)
                            .order(created_at: :desc)
                            .limit(50)
                            .reverse
  end

  def new
    @cohort = Cohort.new
    authorize @cohort
  end

  def create
    @cohort = Cohort.new(cohort_params)
    @cohort.creator = current_user
    authorize @cohort

    if @cohort.save
      redirect_to @cohort, notice: "Cohort created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @cohort
  end

  def update
    authorize @cohort
    if @cohort.update(cohort_params)
      @cohort.header_image.purge if params[:cohort][:remove_header_image] == "1"
      redirect_to @cohort, notice: "Cohort updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @cohort
    @cohort.discard
    redirect_to cohorts_path, notice: "Cohort archived."
  end

  private

  def set_cohort
    @cohort = Cohort.kept.find(params[:id])
  end

  def cohort_params
    params.require(:cohort).permit(:name, :description, :retreat_location, :retreat_start_date, :retreat_end_date, :header_image)
  end

  def policy_scope_required?
    action_name == "index"
  end
end
