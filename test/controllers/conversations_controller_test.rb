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

  # New

  test "new renders the new message page" do
    sign_in @admin
    get new_conversation_path
    assert_response :success
    assert_match "New Message", response.body
  end

  test "new requires authentication" do
    get new_conversation_path
    assert_redirected_to new_user_session_path
  end

  # Create

  test "create finds or creates conversation and redirects" do
    sign_in @admin
    post conversations_path, params: { recipient_id: @attendee.id }
    assert_redirected_to conversation_path(@conversation)
  end

  test "create makes new conversation with new recipient" do
    @attendee_two.update_column(:dm_privacy, 2) # everyone
    sign_in @admin
    assert_difference "Conversation.count" do
      post conversations_path, params: { recipient_id: @attendee_two.id }
    end
    assert_redirected_to conversation_path(Conversation.last)
  end

  test "create with body creates conversation and first message" do
    @attendee_two.update_column(:dm_privacy, 2)
    sign_in @admin
    assert_difference [ "Conversation.count", "DirectMessage.count" ] do
      post conversations_path, params: { recipient_id: @attendee_two.id, body: "Hello there!" }
    end
    conversation = Conversation.last
    assert_redirected_to conversation_path(conversation)
    assert_equal "Hello there!", conversation.direct_messages.last.body
    assert_equal @admin, conversation.direct_messages.last.sender
  end

  test "create without body does not create a message" do
    sign_in @admin
    assert_no_difference "DirectMessage.count" do
      post conversations_path, params: { recipient_id: @attendee.id }
    end
    assert_redirected_to conversation_path(@conversation)
  end

  test "create with recipient_ids creates group conversation" do
    @attendee_two.update_column(:dm_privacy, 2)
    sign_in @admin
    assert_difference "Conversation.count" do
      post conversations_path, params: { recipient_ids: [ @attendee.id, @attendee_two.id ], body: "Hello group!" }
    end
    conversation = Conversation.last
    assert_redirected_to conversation_path(conversation)
    assert_equal 3, conversation.participants.count
    assert_equal "Hello group!", conversation.direct_messages.last.body
  end

  test "create with recipient_ids reuses existing group conversation" do
    @attendee_two.update_column(:dm_privacy, 2)
    sign_in @admin
    convo = Conversation.between(@admin, @attendee, @attendee_two)
    assert_no_difference "Conversation.count" do
      post conversations_path, params: { recipient_ids: [ @attendee.id, @attendee_two.id ] }
    end
    assert_redirected_to conversation_path(convo)
  end

  test "create prevents self-messaging" do
    sign_in @admin
    assert_no_difference "Conversation.count" do
      post conversations_path, params: { recipient_id: @admin.id }
    end
    assert_redirected_to conversations_path
    assert_equal "Cannot message yourself.", flash[:alert]
  end

  test "create requires authentication" do
    post conversations_path, params: { recipient_id: @attendee.id }
    assert_redirected_to new_user_session_path
  end

  # DM privacy

  test "create is blocked when recipient privacy is nobody" do
    @attendee.update_column(:dm_privacy, 0) # nobody
    sign_in @attendee_two
    assert_no_difference "Conversation.count" do
      post conversations_path, params: { recipient_id: @attendee.id }
    end
    assert_redirected_to new_conversation_path
    assert_match "not accepting direct messages", flash[:alert]
  end

  test "create is blocked when recipient privacy is cohort_members and sender is not in shared cohort" do
    @attendee.update_column(:dm_privacy, 1) # cohort_members
    sign_in @attendee_two # attendee_two shares no cohort with attendee
    assert_no_difference "Conversation.count" do
      post conversations_path, params: { recipient_id: @attendee.id }
    end
    assert_redirected_to new_conversation_path
    assert_match "not accepting direct messages", flash[:alert]
  end

  test "create succeeds when recipient privacy is cohort_members and sender shares a cohort" do
    @attendee.update_column(:dm_privacy, 1) # cohort_members
    sign_in @admin # admin and attendee share kabul_retreat
    post conversations_path, params: { recipient_id: @attendee.id }
    assert_redirected_to conversation_path(@conversation)
  end

  test "create succeeds when recipient privacy is everyone" do
    @attendee_two.update_column(:dm_privacy, 2) # everyone
    sign_in @admin
    post conversations_path, params: { recipient_id: @attendee_two.id }
    assert_response :redirect
    assert_nil flash[:alert]
  end

  test "admin can message recipient regardless of privacy setting" do
    @attendee.update_column(:dm_privacy, 0) # nobody
    sign_in @admin
    post conversations_path, params: { recipient_id: @attendee.id }
    assert_redirected_to conversation_path(@conversation)
    assert_nil flash[:alert]
  end
end
