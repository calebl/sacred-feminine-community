module ApplicationHelper
  def total_unread_count(user)
    dm_unread = user.conversations
                    .includes(:conversation_participants, :direct_messages)
                    .sum { |c| c.unread_count(user) }

    cohort_unread = user.cohorts
                        .includes(:cohort_memberships, :chat_messages)
                        .sum { |c| c.unread_count(user) }

    dm_unread + cohort_unread
  end
end
