require "test_helper"

class DirectMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @conversation = conversations(:admin_attendee_convo)
  end

  test "participant can send a message" do
    sign_in @admin
    assert_difference "DirectMessage.count" do
      post conversation_direct_messages_path(@conversation),
        params: { direct_message: { body: "Hello there!" } }
    end
    assert_response :redirect
  end

  test "participant can send via turbo_stream" do
    sign_in @admin
    assert_difference "DirectMessage.count" do
      post conversation_direct_messages_path(@conversation),
        params: { direct_message: { body: "Hello there!" } },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "turbo_stream response removes no_messages_placeholder" do
    sign_in @admin

    post conversation_direct_messages_path(@conversation),
      params: { direct_message: { body: "First message!" } },
      as: :turbo_stream

    assert_response :success
    assert_includes response.body, "no_messages_placeholder"
    assert_includes response.body, "remove"
  end

  test "message is assigned to current user as sender" do
    sign_in @attendee
    post conversation_direct_messages_path(@conversation),
      params: { direct_message: { body: "From attendee" } }
    assert_equal @attendee, DirectMessage.last.sender
  end

  test "sending a message touches the conversation" do
    sign_in @admin
    original_updated_at = @conversation.updated_at

    travel 1.minute do
      post conversation_direct_messages_path(@conversation),
        params: { direct_message: { body: "New message" } }
    end

    assert @conversation.reload.updated_at > original_updated_at
  end

  test "non-participant cannot send a message" do
    sign_in @attendee_two
    assert_no_difference "DirectMessage.count" do
      post conversation_direct_messages_path(@conversation),
        params: { direct_message: { body: "Should fail" } }
    end
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot send a message" do
    post conversation_direct_messages_path(@conversation),
      params: { direct_message: { body: "Should fail" } }
    assert_redirected_to new_user_session_path
  end

  test "blank body does not create message" do
    sign_in @admin
    assert_no_difference "DirectMessage.count" do
      post conversation_direct_messages_path(@conversation),
        params: { direct_message: { body: "" } }
    end
    assert_redirected_to conversation_path(@conversation)
  end
end
