class MentionSearchesController < ApplicationController
  before_action :authenticate_user!

  def index
    skip_authorization

    @users = if params[:q].present?
      search_mentionable_users(params[:q].strip)
    else
      User.none
    end

    render layout: false
  end

  private

  def search_mentionable_users(query)
    scope = base_scope_for_context
    return User.none unless scope

    scope
      .with_attached_avatar
      .where.not(id: current_user.id)
      .where("name LIKE ?", "%#{User.sanitize_sql_like(query)}%")
      .order(:name)
      .limit(10)
  end

  def base_scope_for_context
    if params[:cohort_id].present?
      cohort = Cohort.kept.find_by(id: params[:cohort_id])
      return nil unless cohort&.member?(current_user) || current_user.admin?
      User.kept.where(id: cohort.members.kept.select(:id)).or(User.kept.where(role: :admin))
    elsif params[:group_id].present?
      group = Group.kept.find_by(id: params[:group_id])
      return nil unless group&.member?(current_user) || current_user.admin?
      User.kept.where(id: group.members.kept.select(:id)).or(User.kept.where(role: :admin))
    elsif params[:conversation_id].present?
      conversation = Conversation.find_by(id: params[:conversation_id])
      return nil unless conversation&.participants&.include?(current_user)
      conversation.participants.kept
    end
  end
end
