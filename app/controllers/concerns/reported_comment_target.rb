module ReportedCommentTarget
  private

  def load_reported_comment_target(comments)
    target = comments.find_by(id: params[:reported_comment_id])
    return unless target

    @reported_comment_id = target.id
    @reported_comment_ancestor_ids = []
    target = target.parent
    while target
      @reported_comment_ancestor_ids << target.id
      target = target.parent
    end
  end
end
