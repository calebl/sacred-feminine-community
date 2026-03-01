require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test ".between finds existing conversation" do
    convo = Conversation.between(users(:admin), users(:attendee))
    assert_equal conversations(:admin_attendee_convo), convo
  end

  test ".between creates new conversation if none exists" do
    assert_difference "Conversation.count" do
      Conversation.between(users(:admin), users(:attendee_two))
    end
  end

  test ".between creates participants for new conversation" do
    convo = Conversation.between(users(:admin), users(:attendee_two))
    assert_includes convo.participants, users(:admin)
    assert_includes convo.participants, users(:attendee_two)
  end

  test "other_participant returns the other user" do
    convo = conversations(:admin_attendee_convo)
    assert_equal users(:attendee), convo.other_participant(users(:admin))
    assert_equal users(:admin), convo.other_participant(users(:attendee))
  end

  test "unread_count returns 0 with no messages" do
    convo = conversations(:admin_attendee_convo)
    assert_equal 0, convo.unread_count(users(:admin))
  end

  test "unread_count counts messages after last_read_at" do
    convo = conversations(:admin_attendee_convo)
    participant = convo.conversation_participants.find_by(user: users(:admin))
    participant.update!(last_read_at: 1.hour.ago)

    convo.direct_messages.create!(sender: users(:attendee), body: "New message")

    assert_equal 1, convo.unread_count(users(:admin))
  end

  test "unread_count counts all messages when last_read_at is nil" do
    convo = conversations(:admin_attendee_convo)
    convo.direct_messages.create!(sender: users(:attendee), body: "First message")
    convo.direct_messages.create!(sender: users(:attendee), body: "Second message")

    assert_equal 2, convo.unread_count(users(:admin))
  end

  test "unread_count excludes messages sent by the user" do
    convo = conversations(:admin_attendee_convo)
    participant = convo.conversation_participants.find_by(user: users(:admin))
    participant.update!(last_read_at: 1.hour.ago)

    convo.direct_messages.create!(sender: users(:attendee), body: "From attendee")
    convo.direct_messages.create!(sender: users(:admin), body: "From admin")

    assert_equal 1, convo.unread_count(users(:admin))
  end

  test "unread_count excludes own messages when last_read_at is nil" do
    convo = conversations(:admin_attendee_convo)
    convo.direct_messages.create!(sender: users(:attendee), body: "From attendee")
    convo.direct_messages.create!(sender: users(:admin), body: "From admin")

    assert_equal 1, convo.unread_count(users(:admin))
  end

  test "last_message returns the most recent direct message" do
    convo = conversations(:admin_attendee_convo)
    convo.direct_messages.create!(sender: users(:admin), body: "First")
    last = convo.direct_messages.create!(sender: users(:attendee), body: "Second")

    assert_equal last, convo.last_message
  end

  test "last_message returns nil when no messages" do
    convo = conversations(:admin_attendee_convo)
    assert_nil convo.last_message
  end
end
