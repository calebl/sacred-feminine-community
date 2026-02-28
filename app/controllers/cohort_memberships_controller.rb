class CohortMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cohort

  def create
    authorize @cohort, :manage_members?
    user = User.find(params[:user_id])
    membership = @cohort.cohort_memberships.build(user: user)

    if membership.save
      redirect_to @cohort, notice: "#{user.name} added to cohort."
    else
      redirect_to @cohort, alert: membership.errors.full_messages.join(", ")
    end
  end

  def destroy
    authorize @cohort, :manage_members?
    membership = @cohort.cohort_memberships.find(params[:id])
    membership.destroy
    redirect_to @cohort, notice: "Member removed from cohort."
  end

  private

  def set_cohort
    @cohort = Cohort.find(params[:cohort_id])
  end
end
