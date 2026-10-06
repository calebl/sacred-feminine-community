module ReportedCommentTarget
  private

  def load_reported_comment_target(comments)
    hidden_user_ids = current_user.hidden_content_user_ids
    target = comments.where.not(user_id: hidden_user_ids).find_by(id: params[:reported_comment_id])
    return unless target

    ancestor_ids = []
    ancestor = target.parent
    while ancestor
      return if hidden_user_ids.include?(ancestor.user_id)

      ancestor_ids << ancestor.id
      ancestor = ancestor.parent
    end

    @reported_comment_id = target.id
    @reported_comment_ancestor_ids = ancestor_ids
  end
end
