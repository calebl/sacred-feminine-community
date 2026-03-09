module ApplicationHelper
  def strip_mentions(text)
    return "" if text.blank?
    text.gsub(Mentionable::MENTION_PATTERN) { "@#{$1}" }
  end

  def render_with_mentions(text)
    return "".html_safe if text.blank?

    escaped = ERB::Util.html_escape(text)

    result = escaped.gsub(Mentionable::MENTION_PATTERN) do
      name = $1
      id = $2
      %(<a href="#{profile_path(id)}" class="text-sf-gold font-semibold hover:underline">@#{name}</a>)
    end

    result.html_safe
  end

  def help_requests_need_attention?
    current_user&.admin? && HelpRequest.needs_admin_attention.exists?
  end

  def total_unread_count(user)
    user.total_unread_count
  end

  def notification_icon_bg(notification)
    case notification.event_type
    when "mention"
      "bg-sf-gold/20 dark:bg-sf-gold/10 text-sf-gold"
    when "direct_message"
      "bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400"
    when "new_comment"
      "bg-green-100 dark:bg-green-900/30 text-green-600 dark:text-green-400"
    when "new_member"
      "bg-sf-gold/20 dark:bg-sf-gold/10 text-sf-gold"
    else
      "bg-gray-100 dark:bg-gray-700 text-gray-500"
    end
  end
end
