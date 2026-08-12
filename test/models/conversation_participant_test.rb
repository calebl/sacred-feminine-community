require "test_helper"

class ConversationParticipantTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "requires a user to be unique within a conversation" do
    duplicate = ConversationParticipant.new(
      conversation: conversations.admin_attendee_convo,
      user: users.admin
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "the same user may participate in different conversations" do
    other = Conversation.create!
    participant = ConversationParticipant.new(conversation: other, user: users.admin)

    assert participant.valid?
  end

  # Reading a conversation is what clears the unread badge, and the badge only
  # refreshes live if touching last_read_at enqueues the broadcast job.

  test "updating last_read_at enqueues an unread badge broadcast" do
    participant = conversation_participants.attendee_in_convo

    assert_enqueued_with(job: BroadcastUnreadBadgeJob, args: [ participant.user_id ]) do
      participant.update!(last_read_at: Time.current)
    end
  end

  test "changing another attribute does not enqueue an unread badge broadcast" do
    participant = conversation_participants.attendee_in_convo

    assert_no_enqueued_jobs only: BroadcastUnreadBadgeJob do
      participant.touch
    end
  end

  test "marking a conversation as read enqueues a badge broadcast for that reader" do
    conversation = conversations.admin_attendee_convo
    reader = users.attendee

    assert_enqueued_with(job: BroadcastUnreadBadgeJob, args: [ reader.id ]) do
      conversation.mark_as_read_by(reader)
    end
  end
end
