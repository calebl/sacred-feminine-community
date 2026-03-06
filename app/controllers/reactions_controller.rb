class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reactable

  def create
    existing = @reactable.reactions.find_by(user: current_user)

    if existing
      if existing.emoji == params[:emoji]
        authorize existing, :destroy?
        existing.destroy!
      else
        authorize existing, :destroy?
        existing.update!(emoji: params[:emoji])
      end
    else
      reaction = @reactable.reactions.build(user: current_user, emoji: params[:emoji])
      authorize reaction
      reaction.save!
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "reactions_for_#{@reactable.class.name.underscore}_#{@reactable.id}",
          partial: "reactions/reactions",
          locals: { reactable: @reactable.reload }
        )
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  ALLOWED_REACTABLE_TYPES = %w[Post GroupPost FeedPost PostComment GroupPostComment FeedPostComment].freeze

  def set_reactable
    type = params[:reactable_type]
    raise ActiveRecord::RecordNotFound unless type.in?(ALLOWED_REACTABLE_TYPES)

    @reactable = type.constantize.find(params[:reactable_id])
  end
end
