class GroupMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group

  def create
    authorize @group, :join?
    membership = @group.group_memberships.build(user: current_user)

    if membership.save
      @group.group_chat_messages.create!(
        user: current_user,
        body: "#{current_user.name} joined the group",
        system_message: true
      )
      redirect_to @group, notice: "You joined the group."
    else
      redirect_to @group, alert: membership.errors.full_messages.join(", ")
    end
  end

  def destroy
    authorize @group, :leave?
    membership = @group.group_memberships.find_by!(user: current_user)
    membership.destroy
    redirect_to groups_path, notice: "You left the group."
  end

  private

  def set_group
    @group = Group.kept.find(params[:group_id])
  end
end
