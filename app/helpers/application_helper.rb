module ApplicationHelper
  def total_unread_count(user)
    dm_unread = user.conversations
                    .includes(:conversation_participants, :direct_messages)
                    .sum { |c| c.unread_count(user) }

    cohorts = user.cohorts.includes(:cohort_memberships, :chat_messages, :posts)

    cohort_unread = cohorts.sum { |c| c.unread_count(user) }

    post_unread = cohorts.sum { |c| c.unread_post_count(user) }

    commented_post_ids = user.post_comments.select(:post_id).distinct
    comment_unread = Post.where(id: commented_post_ids)
                         .includes(:post_comments, :post_reads)
                         .sum { |p| p.unread_comment_count(user) > 0 ? 1 : 0 }

    dm_unread + cohort_unread + post_unread + comment_unread
  end
end
