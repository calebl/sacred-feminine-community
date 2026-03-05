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

  test "other_participants returns the other users" do
    convo = conversations(:admin_attendee_convo)
    assert_equal [ users(:attendee) ], convo.other_participants(users(:admin)).to_a
    assert_equal [ users(:admin) ], convo.other_participants(users(:attendee)).to_a
  end

  test ".between creates group conversation with three users" do
    assert_difference "Conversation.count" do
      convo = Conversation.between(users(:admin), users(:attendee), users(:attendee_two))
      assert_equal 3, convo.participants.count
      assert_includes convo.participants, users(:admin)
      assert_includes convo.participants, users(:attendee)
      assert_includes convo.participants, users(:attendee_two)
    end
  end

  test ".between reuses existing group conversation" do
    convo = Conversation.between(users(:admin), users(:attendee), users(:attendee_two))
    assert_no_difference "Conversation.count" do
      found = Conversation.between(users(:attendee_two), users(:admin), users(:attendee))
      assert_equal convo, found
    end
  end

  test ".between does not confuse two-person and three-person conversations" do
    two_person = conversations(:admin_attendee_convo)
    three_person = Conversation.between(users(:admin), users(:attendee), users(:attendee_two))
    assert_not_equal two_person, three_person
  end

  test ".between accepts array of users" do
    convo = Conversation.between([ users(:admin), users(:attendee), users(:attendee_two) ])
    assert_equal 3, convo.participants.count
  end

  test "other_participants returns multiple for group conversation" do
    convo = Conversation.between(users(:admin), users(:attendee), users(:attendee_two))
    others = convo.other_participants(users(:admin))
    assert_equal 2, others.count
    assert_includes others, users(:attendee)
    assert_includes others, users(:attendee_two)
  end

  test "display_name returns comma-separated other participant names" do
    convo = conversations(:admin_attendee_convo)
    assert_equal "Jane Attendee", convo.display_name(users(:admin))
  end

  test "display_name returns multiple names for group conversation" do
    convo = Conversation.between(users(:admin), users(:attendee), users(:attendee_two))
    name = convo.display_name(users(:admin))
    assert_includes name, "Jane Attendee"
    assert_includes name, "Sarah Member"
  end

  test "display_name marks discarded participants as removed" do
    convo = conversations(:admin_attendee_convo)
    users(:attendee).discard
    assert_equal "Jane Attendee (removed)", convo.display_name(users(:admin))
  end

  test "send_message creates a direct message and touches the conversation" do
    convo = conversations(:admin_attendee_convo)
    original_updated_at = convo.updated_at

    travel_to 1.minute.from_now do
      convo.send_message(from: users(:admin), body: "Hello!")
    end

    assert_equal "Hello!", convo.direct_messages.last.body
    assert_equal users(:admin), convo.direct_messages.last.sender
    assert convo.reload.updated_at > original_updated_at
  end

  test "send_message does nothing when body is blank" do
    convo = conversations(:admin_attendee_convo)
    assert_no_difference "DirectMessage.count" do
      convo.send_message(from: users(:admin), body: "")
      convo.send_message(from: users(:admin), body: nil)
    end
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
