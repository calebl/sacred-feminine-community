module ApplicationHelper
  def strip_mentions(text)
    return "" if text.blank?
    text.gsub(Mentionable::MENTION_PATTERN) { "@#{$1}" }
  end

  URL_PATTERN = %r{https?://[^\s<>"')\]]+[^\s<>"')\].,:;!?]}

  def format_user_content(text)
    return "".html_safe if text.blank?

    escaped = ERB::Util.html_escape(text)

    result = escaped.gsub(URL_PATTERN) do |url|
      %(<a href="#{url}" class="text-sf-gold underline hover:text-sf-gold/80" target="_blank" rel="noopener noreferrer">#{url}</a>)
    end

    hidden_ids = viewer_hidden_content_user_ids
    result = result.gsub(Mentionable::MENTION_PATTERN) do
      name = $1
      id = $2.to_i
      if hidden_ids.include?(id)
        "@#{name}"
      else
        %(<a href="#{profile_path(id)}" class="text-sf-gold font-semibold hover:underline">@#{name}</a>)
      end
    end

    result.html_safe
  end

  # Where members and visitors can reach the people who run the community.
  def contact_email
    ENV.fetch("CONTACT_EMAIL", "community@sacredfeminine.com")
  end

  # "Report" link for content someone else wrote; nothing for the viewer's own.
  def report_link(reportable, author:, **options)
    return if author == current_user

    link_to "Report", new_report_path(reportable_type: reportable.class.name, reportable_id: reportable.id),
            data: { turbo_frame: "_top" }, **options
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    Redcarpet::Markdown.new(renderer).render(text).html_safe
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
    when "help_request", "help_request_reply"
      "bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400"
    else
      "bg-gray-100 dark:bg-gray-700 text-gray-500"
    end
  end

  private

  # Ids of users whose content is hidden from the viewer, so e.g. their @mentions
  # render as plain text rather than profile links. Returns [] outside a request
  # (e.g. helper tests) where no Warden session exists.
  def viewer_hidden_content_user_ids
    return [] unless respond_to?(:current_user)

    current_user&.hidden_content_user_ids || []
  rescue Devise::MissingWarden
    []
  end
end
