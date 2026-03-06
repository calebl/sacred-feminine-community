require "test_helper"
require "turbo/broadcastable/test_helper"

class DirectMessageTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper
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

  test "notification broadcasts to recipient with dm_notifications enabled" do
    conversation = conversations(:admin_attendee_convo)
    sender = users(:admin)

    assert_turbo_stream_broadcasts [ users(:attendee), :dm_notifications ] do
      DirectMessage.create!(body: "Hello!", conversation: conversation, sender: sender)
    end
  end

  test "notification does not broadcast to sender" do
    conversation = conversations(:admin_attendee_convo)
    sender = users(:admin)

    assert_no_turbo_stream_broadcasts [ sender, :dm_notifications ] do
      DirectMessage.create!(body: "Hello!", conversation: conversation, sender: sender)
    end
  end

  test "notification skips recipients with dm_notifications disabled" do
    conversation = conversations(:admin_attendee_convo)
    sender = users(:admin)
    recipient = users(:attendee)
    recipient.update!(dm_notifications: false)

    assert_no_turbo_stream_broadcasts [ recipient, :dm_notifications ] do
      DirectMessage.create!(body: "Hello!", conversation: conversation, sender: sender)
    end
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
