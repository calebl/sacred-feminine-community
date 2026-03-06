class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reactable, only: [ :create ]
  before_action :set_reaction, only: [ :update, :destroy ]

  def create
    reaction = @reactable.reactions.build(user: current_user, emoji: params[:emoji])
    authorize reaction

    if reaction.save
      render_reaction_stream(reaction.reactable)
    else
      head :unprocessable_entity
    end
  end

  def update
    authorize @reaction

    if @reaction.update(emoji: params[:emoji])
      render_reaction_stream(@reaction.reactable)
    else
      head :unprocessable_entity
    end
  end

  def destroy
    authorize @reaction
    reactable = @reaction.reactable
    @reaction.destroy

    render_reaction_stream(reactable)
  end

  private

  REACTABLE_TYPES = {
    "Post" => Post,
    "GroupPost" => GroupPost,
    "FeedPost" => FeedPost,
    "PostComment" => PostComment,
    "GroupPostComment" => GroupPostComment,
    "FeedPostComment" => FeedPostComment
  }.freeze

  def set_reactable
    klass = REACTABLE_TYPES[params[:reactable_type]]
    raise ActiveRecord::RecordNotFound unless klass

    @reactable = klass.find(params[:reactable_id])
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
