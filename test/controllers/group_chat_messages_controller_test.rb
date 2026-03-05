require "test_helper"

class GroupChatMessagesControllerTest < ActionDispatch::IntegrationTest
  test "member can send a chat message" do
    sign_in users(:attendee)
    group = groups(:book_club)

    assert_difference "GroupChatMessage.count" do
      post group_group_chat_messages_path(group), params: {
        group_chat_message: { body: "Hello everyone!" }
      }
    end
    assert_redirected_to group_path(group)
  end

  test "member can send via turbo_stream" do
    sign_in users(:attendee)
    group = groups(:book_club)

    assert_difference "GroupChatMessage.count" do
      post group_group_chat_messages_path(group),
        params: { group_chat_message: { body: "Hello via turbo!" } },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "turbo_stream response removes no_messages_placeholder" do
    sign_in users(:attendee)
    group = groups(:book_club)

    post group_group_chat_messages_path(group),
      params: { group_chat_message: { body: "First message!" } },
      as: :turbo_stream

    assert_response :success
    assert_includes response.body, "no_messages_placeholder"
    assert_includes response.body, "remove"
  end

  test "non-member cannot send a chat message" do
    sign_in users(:attendee_two)
    group = groups(:book_club)

    assert_no_difference "GroupChatMessage.count" do
      post group_group_chat_messages_path(group), params: {
        group_chat_message: { body: "Trying to sneak in!" }
      }
    end
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot send messages" do
    group = groups(:book_club)
    assert_no_difference "GroupChatMessage.count" do
      post group_group_chat_messages_path(group), params: {
        group_chat_message: { body: "Not logged in" }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "blank body redirects with alert" do
    sign_in users(:attendee)
    group = groups(:book_club)

    assert_no_difference "GroupChatMessage.count" do
      post group_group_chat_messages_path(group), params: {
        group_chat_message: { body: "" }
      }
    end
    assert_redirected_to group_path(group)
    assert_equal "Message could not be sent.", flash[:alert]
  end
end
