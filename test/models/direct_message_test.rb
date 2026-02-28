require "test_helper"

class DirectMessageTest < ActiveSupport::TestCase
  test "requires body" do
    msg = DirectMessage.new(conversation: conversations(:admin_attendee_convo), sender: users(:admin))
    assert_not msg.valid?
    assert_includes msg.errors[:body], "can't be blank"
  end

  test "valid with all attributes" do
    msg = DirectMessage.new(
      conversation: conversations(:admin_attendee_convo),
      sender: users(:admin),
      body: "Hello!"
    )
    assert msg.valid?
  end

  test "body is encrypted in the database" do
    msg = DirectMessage.create!(
      conversation: conversations(:admin_attendee_convo),
      sender: users(:admin),
      body: "Secret message"
    )

    # Read the raw value from the database
    raw = ActiveRecord::Base.connection.select_value(
      "SELECT body FROM direct_messages WHERE id = #{msg.id}"
    )

    # The raw DB value should NOT be the plaintext
    assert_not_equal "Secret message", raw
    # But reading through the model should decrypt it
    assert_equal "Secret message", msg.reload.body
  end
end
