require "test_helper"

class DirectMessageTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
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

  test "rejects body over 5000 characters" do
    msg = DirectMessage.new(
      conversation: conversations(:admin_attendee_convo),
      sender: users(:admin),
      body: "x" * 5001
    )
    assert_not msg.valid?
    assert_includes msg.errors[:body], "is too long (maximum is 5000 characters)"
  end

  test "broadcast callback eager-loads sender avatar" do
    conversation = conversations(:admin_attendee_convo)
    sender = users(:admin)

    # Verify create succeeds without errors (broadcast callback runs)
    message = DirectMessage.create!(
      body: "Broadcast test",
      conversation: conversation,
      sender: sender
    )

    # Verify the eager-loaded query returns the message with associations
    loaded = DirectMessage.includes(sender: { avatar_attachment: :blob }).find(message.id)
    assert_equal sender, loaded.sender
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
