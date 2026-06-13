class UserBlocksController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize UserBlock
    @user_blocks = current_user.user_blocks.includes(:blocked).merge(User.kept.order(:name))
    @blocked_users = @user_blocks.map(&:blocked)
    @block_ids_by_user = @user_blocks.to_h { |b| [ b.blocked_id, b.id ] }
  end

  def create
    @blocked_user = User.kept.find(params[:blocked_id])
    @block = current_user.user_blocks.build(blocked: @blocked_user)
    authorize @block

    if @block.save
      redirect_back fallback_location: profile_path(@blocked_user),
                    notice: "#{@blocked_user.name} has been blocked."
    else
      redirect_back fallback_location: profile_path(@blocked_user),
                    alert: @block.errors.full_messages.to_sentence
    end
  end

  def destroy
    @block = current_user.user_blocks.find(params[:id])
    authorize @block
    blocked_name = @block.blocked.name
    @block.destroy
    redirect_back fallback_location: user_blocks_path,
                  notice: "#{blocked_name} has been unblocked."
  end
end
