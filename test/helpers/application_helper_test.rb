require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "format_user_content converts mention syntax to links" do
    result = format_user_content("Hello @[Jane](1)")
    assert_includes result, "<a href="
    assert_includes result, "@Jane"
    assert_includes result, "text-sf-gold"
    assert result.html_safe?
  end

  test "format_user_content escapes HTML in surrounding text" do
    result = format_user_content('<script>alert("xss")</script> @[Jane](1)')
    assert_not_includes result, "<script>"
    assert_includes result, "&lt;script&gt;"
    assert_includes result, "@Jane"
  end

  test "format_user_content handles nil" do
    assert_equal "", format_user_content(nil)
  end

  test "format_user_content handles blank" do
    assert_equal "", format_user_content("")
  end

  test "format_user_content handles text with no mentions" do
    result = format_user_content("Just a regular message")
    assert_equal "Just a regular message", result
  end

  test "format_user_content handles multiple mentions" do
    result = format_user_content("@[Jane](1) and @[Bob](2)")
    assert_includes result, "@Jane"
    assert_includes result, "@Bob"
  end

  test "format_user_content generates correct profile links" do
    result = format_user_content("@[Jane](42)")
    assert_includes result, "/profiles/42"
  end

  test "format_user_content auto-links http URLs" do
    result = format_user_content("Visit http://example.com for more")
    assert_includes result, '<a href="http://example.com"'
    assert_includes result, 'target="_blank"'
    assert_includes result, 'rel="noopener noreferrer"'
    assert_includes result, ">http://example.com</a>"
  end

  test "format_user_content auto-links https URLs" do
    result = format_user_content("Check https://example.com/path?q=1")
    assert_includes result, '<a href="https://example.com/path?q=1"'
    assert_includes result, ">https://example.com/path?q=1</a>"
  end

  test "format_user_content auto-links URLs alongside mentions" do
    result = format_user_content("@[Jane](1) shared https://example.com")
    assert_includes result, "@Jane</a>"
    assert_includes result, ">https://example.com</a>"
  end

  test "format_user_content does not double-link mention hrefs" do
    result = format_user_content("@[Jane](1)")
    # The profile link href should not itself be turned into a clickable URL
    assert_equal 1, result.scan("<a ").length
  end

  test "format_user_content auto-links multiple URLs" do
    result = format_user_content("See https://a.com and http://b.com")
    assert_equal 2, result.scan('target="_blank"').length
  end

  test "format_user_content does not linkify plain text" do
    result = format_user_content("no links here")
    assert_not_includes result, "<a "
  end

  test "format_user_content strips trailing punctuation from URLs" do
    result = format_user_content("Visit https://example.com.")
    assert_includes result, ">https://example.com</a>."
  end

  test "format_user_content handles single-char URL path without trailing punct" do
    result = format_user_content("See https://a.co/b")
    assert_includes result, ">https://a.co/b</a>"
  end

  test "strip_mentions replaces mention syntax with plain @Name" do
    assert_equal "Hello @Jane!", strip_mentions("Hello @[Jane](1)!")
  end

  test "strip_mentions handles multiple mentions" do
    assert_equal "@Jane and @Bob", strip_mentions("@[Jane](1) and @[Bob](2)")
  end

  test "strip_mentions handles nil and blank" do
    assert_equal "", strip_mentions(nil)
    assert_equal "", strip_mentions("")
  end

  test "markdown renders bold and italic" do
    result = markdown("**bold** and *italic*")
    assert_includes result, "<strong>bold</strong>"
    assert_includes result, "<em>italic</em>"
    assert result.html_safe?
  end

  test "markdown uses hard wraps" do
    result = markdown("line one\nline two")
    assert_includes result, "<br>"
  end

  test "total_unread_count delegates to the user" do
    user = users.admin
    assert_equal user.total_unread_count, total_unread_count(user)
  end

  test "help_requests_need_attention returns true when admin has open requests" do
    def self.current_user; users.admin; end
    assert help_requests_need_attention?
  end

  test "help_requests_need_attention returns false for a non-admin" do
    def self.current_user; users.attendee; end
    assert_not help_requests_need_attention?
  end

  test "help_requests_need_attention returns false when current_user is nil" do
    def self.current_user; nil; end
    assert_not help_requests_need_attention?
  end

  test "notification_icon_bg returns styling for each known event type" do
    %w[mention direct_message new_comment new_member help_request help_request_reply].each do |event|
      notification = Notification.new(event_type: event)
      assert notification_icon_bg(notification).present?, "expected styling for #{event}"
    end
  end

  test "notification_icon_bg falls back for unknown event types" do
    notification = Notification.new(event_type: "unknown_event")
    result = notification_icon_bg(notification)
    assert_includes result, "bg-gray-100"
  end

  test "notification_icon_bg distinguishes help_request and mention styling" do
    assert_includes notification_icon_bg(Notification.new(event_type: "mention")), "sf-gold"
    assert_includes notification_icon_bg(Notification.new(event_type: "direct_message")), "blue"
    assert_includes notification_icon_bg(Notification.new(event_type: "new_comment")), "green"
    assert_includes notification_icon_bg(Notification.new(event_type: "help_request")), "purple"
  end
end
