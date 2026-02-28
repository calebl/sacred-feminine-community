class CohortsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort, only: [ :show, :edit, :update, :destroy ]

  def index
    skip_authorization
    @cohorts = policy_scope(Cohort).includes(:members).order(retreat_date: :desc)
  end

  def show
    authorize @cohort
    @members = @cohort.members
    @chat_messages = @cohort.chat_messages
                            .includes(:user)
                            .order(created_at: :asc)
                            .last(50)
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
      redirect_to @cohort, notice: "Cohort updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @cohort
    @cohort.destroy
    redirect_to cohorts_path, notice: "Cohort deleted."
  end

  private

  def set_cohort
    @cohort = Cohort.find(params[:id])
  end

  def cohort_params
    params.require(:cohort).permit(:name, :description, :retreat_location, :retreat_date)
  end

  def policy_scope_required?
    action_name == "index"
  end
end
