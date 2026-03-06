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
end
