require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @conversation = conversations(:admin_attendee_convo)
  end

  # Index

  test "index lists user's conversations" do
    sign_in @admin
    get conversations_path
    assert_response :success
  end

  test "index requires authentication" do
    get conversations_path
    assert_redirected_to new_user_session_path
  end

  # Show

  test "show displays conversation for participant" do
    sign_in @admin
    get conversation_path(@conversation)
    assert_response :success
  end

  test "show marks conversation as read" do
    sign_in @admin
    participant = @conversation.conversation_participants.find_by(user: @admin)
    assert_nil participant.last_read_at

    get conversation_path(@conversation)

    participant.reload
    assert_not_nil participant.last_read_at
  end

  test "show denies non-participant" do
    sign_in @attendee_two
    get conversation_path(@conversation)
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "show requires authentication" do
    get conversation_path(@conversation)
    assert_redirected_to new_user_session_path
  end

  # Create

  test "create finds or creates conversation and redirects" do
    sign_in @admin
    post conversations_path, params: { recipient_id: @attendee.id }
    assert_redirected_to conversation_path(@conversation)
  end

  test "create makes new conversation with new recipient" do
    sign_in @admin
    assert_difference "Conversation.count" do
      post conversations_path, params: { recipient_id: @attendee_two.id }
    end
    assert_redirected_to conversation_path(Conversation.last)
  end

  test "create requires authentication" do
    post conversations_path, params: { recipient_id: @attendee.id }
    assert_redirected_to new_user_session_path
  end
end
