require "test_helper"

# Broadcast tests prove the models publish to the right streams; these prove the
# rendered pages subscribe to those same streams. Without this pairing either
# side can be renamed on its own and live messaging silently stops working while
# every other test stays green.
class RealtimeMessagingStreamsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users.admin
    @attendee = users.attendee
    @conversation = conversations.admin_attendee_convo
  end

  test "conversation page subscribes to the stream DirectMessage broadcasts the thread to" do
    sign_in @admin
    get conversation_path(@conversation)

    assert_response :success
    assert_includes response.body,
      Turbo::StreamsChannel.signed_stream_name(@conversation),
      "conversation page is not subscribed to the stream broadcast_all appends messages to"
  end

  test "conversation page renders the target broadcast_all appends into" do
    sign_in @admin
    get conversation_path(@conversation)

    # broadcast_append_to targets "direct_messages"; if that container is renamed
    # or removed the appended message has nowhere to land.
    assert_select "#direct_messages"
  end

  test "authenticated layout subscribes to the sender's dm_notifications stream" do
    sign_in @attendee
    get root_path

    assert_includes response.body,
      Turbo::StreamsChannel.signed_stream_name([ @attendee, :dm_notifications ]),
      "layout is not subscribed to the dm_notifications stream broadcast_all toasts to"
    assert_select "#dm_notifications"
  end

  test "authenticated layout subscribes to the unread_badge stream the badge job broadcasts to" do
    sign_in @attendee
    get root_path

    assert_includes response.body,
      Turbo::StreamsChannel.signed_stream_name([ @attendee, :unread_badge ]),
      "layout is not subscribed to the stream BroadcastUnreadBadgeJob broadcasts to"
  end

  test "signed stream names are scoped per user" do
    sign_in @attendee
    get root_path

    # A subscription is only as private as its signed name — the attendee's page
    # must never carry another member's notification stream.
    assert_not_includes response.body,
      Turbo::StreamsChannel.signed_stream_name([ @admin, :dm_notifications ]),
      "one member's page exposed another member's dm_notifications stream"
  end

  test "signed out pages carry no personal streams" do
    get root_path

    assert_not_includes response.body,
      Turbo::StreamsChannel.signed_stream_name([ @attendee, :dm_notifications ])
    assert_not_includes response.body,
      Turbo::StreamsChannel.signed_stream_name([ @attendee, :unread_badge ])
  end
end
