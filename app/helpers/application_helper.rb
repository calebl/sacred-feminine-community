module ApplicationHelper
  MENTION_PATTERN = /@\[([^\]]+)\]\((\d+)\)/

  def render_with_mentions(text)
    return "".html_safe if text.blank?

    escaped = ERB::Util.html_escape(text)

    result = escaped.gsub(MENTION_PATTERN) do
      name = $1
      id = $2
      %(<a href="#{profile_path(id)}" class="text-sf-gold font-semibold hover:underline">@#{name}</a>)
    end

    result.html_safe
  end

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

    mention_unread = Mention.unread.where(user: user).count

    dm_unread + cohort_unread + post_unread + comment_unread + mention_unread
  end
end
