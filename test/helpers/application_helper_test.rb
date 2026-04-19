require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "render_with_mentions converts mention syntax to links" do
    result = render_with_mentions("Hello @[Jane](1)")
    assert_includes result, "<a href="
    assert_includes result, "@Jane"
    assert_includes result, "text-sf-gold"
    assert result.html_safe?
  end

  test "render_with_mentions escapes HTML in surrounding text" do
    result = render_with_mentions('<script>alert("xss")</script> @[Jane](1)')
    assert_not_includes result, "<script>"
    assert_includes result, "&lt;script&gt;"
    assert_includes result, "@Jane"
  end

  test "render_with_mentions handles nil" do
    assert_equal "", render_with_mentions(nil)
  end

  test "render_with_mentions handles blank" do
    assert_equal "", render_with_mentions("")
  end

  test "render_with_mentions handles text with no mentions" do
    result = render_with_mentions("Just a regular message")
    assert_equal "Just a regular message", result
  end

  test "render_with_mentions handles multiple mentions" do
    result = render_with_mentions("@[Jane](1) and @[Bob](2)")
    assert_includes result, "@Jane"
    assert_includes result, "@Bob"
  end

  test "render_with_mentions generates correct profile links" do
    result = render_with_mentions("@[Jane](42)")
    assert_includes result, "/profiles/42"
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
    user = users(:admin)
    assert_equal user.total_unread_count, total_unread_count(user)
  end

  test "help_requests_need_attention returns true when admin has open requests" do
    def self.current_user; users(:admin); end
    assert help_requests_need_attention?
  end

  test "help_requests_need_attention returns false for a non-admin" do
    def self.current_user; users(:attendee); end
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
