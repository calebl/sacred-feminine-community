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

  def total_unread_count(user)
    user.total_unread_count
  end
end
