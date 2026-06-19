require "application_system_test_case"

class MentionControllerTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users.attendee
    @conversation = conversations.admin_attendee_convo
    sign_in @user
  end

  test "dropdown appears above input with last item auto-selected and supports keyboard selection" do
    visit_chat
    message_count_before = DirectMessage.count

    # Typing @name shows dropdown above input with last item highlighted
    mention_input.click
    mention_input.send_keys("@Admin")

    assert_dropdown_visible
    assert_selector "[data-mention-target='dropdown'] button", text: "Admin User"

    input_rect = mention_input.rect
    dropdown = find("[data-mention-target='dropdown']")
    dropdown_bottom = dropdown.rect.y + dropdown.rect.height
    assert dropdown_bottom <= input_rect.y + input_rect.height, "Dropdown should appear above the input bottom edge"

    buttons = all("[data-mention-target='dropdown'] button")
    assert buttons.last[:class].include?("bg-sf-sand/10"), "Last item should be auto-highlighted"

    # Enter selects the highlighted mention without submitting the form
    mention_input.send_keys(:enter)

    assert_dropdown_hidden
    assert_selector "[data-mention-target='input'] .mention-tag", text: "@Admin User"
    assert_equal message_count_before, DirectMessage.count
  end

  test "escape closes the dropdown and clicking a suggestion inserts mention" do
    visit_chat

    # Escape closes dropdown
    mention_input.click
    mention_input.send_keys("@Admin")
    assert_dropdown_visible

    mention_input.send_keys(:escape)
    assert_dropdown_hidden

    # Clicking a suggestion inserts mention tag
    mention_input.send_keys(" @Admin")
    assert_dropdown_visible

    find("[data-mention-target='dropdown'] button", text: "Admin User").click

    assert_dropdown_hidden
    assert_selector "[data-mention-target='input'] .mention-tag", text: "@Admin User"
  end

  test "second mention on same line reopens dropdown when preceded by a non-breaking space" do
    visit_chat

    mention_input.click
    mention_input.send_keys("@Admin")
    assert_dropdown_visible
    mention_input.send_keys(:enter)
    assert_dropdown_hidden
    assert_selector "[data-mention-target='input'] .mention-tag", text: "@Admin User"

    # Real browsers often emit U+00A0 (non-breaking space) when the user presses
    # spacebar adjacent to the trailing nbsp that `select()` leaves after a
    # mention chip. Capybara's send_keys normalizes to a regular space, so
    # inject the nbsp directly via JS to reproduce the real-browser failure mode.
    insert_text_into_mention_input(" @A")

    assert_dropdown_visible
    mention_input.send_keys(:enter)
    assert_dropdown_hidden
    assert_selector "[data-mention-target='input'] .mention-tag", count: 2
  end

  test "arrow keys navigate dropdown items" do
    visit_chat

    mention_input.click
    mention_input.send_keys("@a")

    assert_dropdown_visible
    buttons = all("[data-mention-target='dropdown'] button")

    if buttons.length >= 2
      mention_input.send_keys(:arrow_up)

      buttons = all("[data-mention-target='dropdown'] button")
      assert buttons[-2][:class].include?("bg-sf-sand/10"), "ArrowUp should move highlight to previous item"
    end
  end

  private

  def visit_chat
    visit conversation_path(@conversation)
    assert_selector "[data-mention-target='input']", wait: 5
  end

  def mention_input
    find("[data-mention-target='input']")
  end

  def assert_dropdown_visible
    assert_selector "[data-mention-target='dropdown']:not(.hidden)", wait: 5
  end

  def assert_dropdown_hidden
    assert_selector "[data-mention-target='dropdown'].hidden", visible: false, wait: 5
    assert_no_selector "[data-mention-target='dropdown']:not(.hidden)"
  end

  def insert_text_into_mention_input(text)
    page.execute_script(<<~JS, text)
      const text = arguments[0]
      const input = document.querySelector("[data-mention-target='input']")
      input.focus()

      // Append text to the last text-node descendant so the new characters share
      // a node with the trailing nbsp left by select() — matching how browsers
      // append typed characters into the existing text node.
      const walker = document.createTreeWalker(input, NodeFilter.SHOW_TEXT)
      let last = null
      while (walker.nextNode()) last = walker.currentNode
      if (!last) {
        last = document.createTextNode("")
        input.appendChild(last)
      }
      last.textContent = last.textContent + text

      // Place the cursor at the end of the modified text node.
      const range = document.createRange()
      range.setStart(last, last.textContent.length)
      range.collapse(true)
      const sel = window.getSelection()
      sel.removeAllRanges()
      sel.addRange(range)

      input.dispatchEvent(new InputEvent("input", { bubbles: true, inputType: "insertText", data: text }))
    JS
  end
end
