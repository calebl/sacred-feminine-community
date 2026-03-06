class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reactable, only: [ :create ]
  before_action :set_reaction, only: [ :update, :destroy ]

  def create
    reaction = @reactable.reactions.build(user: current_user, emoji: params[:emoji])
    authorize reaction
    reaction.save!

    render_reaction_stream(reaction.reactable)
  end

  def update
    authorize @reaction
    @reaction.update!(emoji: params[:emoji])

    render_reaction_stream(@reaction.reactable)
  end

  def destroy
    authorize @reaction
    reactable = @reaction.reactable
    @reaction.destroy!

    render_reaction_stream(reactable)
  end

  private

  ALLOWED_REACTABLE_TYPES = %w[Post GroupPost FeedPost PostComment GroupPostComment FeedPostComment].freeze

  def set_reactable
    type = params[:reactable_type]
    raise ActiveRecord::RecordNotFound unless type.in?(ALLOWED_REACTABLE_TYPES)

    @reactable = type.constantize.find(params[:reactable_id])
  end

  def set_reaction
    @reaction = current_user.reactions.find(params[:id])
  end

  def render_reaction_stream(reactable)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "reactions_for_#{reactable.class.name.underscore}_#{reactable.id}",
          partial: "reactions/reactions",
          locals: { reactable: reactable.reload, inline: reactable.class.name.end_with?("Comment") }
        )
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end
end
