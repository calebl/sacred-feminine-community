module UnreadIndicatorsHelper
  # View-facing wrappers around the per-context unread queries on User. They all
  # tolerate a missing current_user (e.g. in helper specs without a session).
  def unread_messages?
    current_user&.unread_messages? || false
  end

  def unread_cohort_ids
    current_user&.unread_cohort_ids || Set.new
  end

  def unread_group_ids
    current_user&.unread_group_ids || Set.new
  end

  # Whether to attach the scroll-into-view observer to a given post/comment.
  def unread_dot_for?(record)
    return false unless current_user

    case record
    when Post then current_user.unread_for_post?(record)
    when PostComment then current_user.unread_for_post_comment?(record)
    when GroupPost then current_user.unread_for_group_post?(record)
    when GroupPostComment then current_user.unread_for_group_post_comment?(record)
    else false
    end
  end
end
