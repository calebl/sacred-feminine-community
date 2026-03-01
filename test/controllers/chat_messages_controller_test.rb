require "test_helper"

class ChatMessagesControllerTest < ActionDispatch::IntegrationTest
  test "member can send a chat message" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    assert_difference "ChatMessage.count" do
      post cohort_chat_messages_path(cohort), params: {
        chat_message: { body: "Hello everyone!" }
      }
    end
    assert_redirected_to cohort_path(cohort)
  end

  test "member can send via turbo_stream" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    assert_difference "ChatMessage.count" do
      post cohort_chat_messages_path(cohort),
        params: { chat_message: { body: "Hello via turbo!" } },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "turbo_stream response removes no_messages_placeholder" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    post cohort_chat_messages_path(cohort),
      params: { chat_message: { body: "First message!" } },
      as: :turbo_stream

    assert_response :success
    assert_includes response.body, "no_messages_placeholder"
    assert_includes response.body, "remove"
  end

  test "non-member cannot send a chat message" do
    sign_in users(:attendee_two)
    cohort = cohorts(:kabul_retreat)

    assert_no_difference "ChatMessage.count" do
      post cohort_chat_messages_path(cohort), params: {
        chat_message: { body: "Trying to sneak in!" }
      }
    end
    assert_redirected_to root_path
  end

  test "admin can send to any cohort" do
    sign_in users(:admin)
    cohort = cohorts(:bali_retreat)

    assert_difference "ChatMessage.count" do
      post cohort_chat_messages_path(cohort), params: {
        chat_message: { body: "Admin message" }
      }
    end
  end

  test "unauthenticated user cannot send messages" do
    cohort = cohorts(:kabul_retreat)
    assert_no_difference "ChatMessage.count" do
      post cohort_chat_messages_path(cohort), params: {
        chat_message: { body: "Not logged in" }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test "blank body redirects with alert" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    assert_no_difference "ChatMessage.count" do
      post cohort_chat_messages_path(cohort), params: {
        chat_message: { body: "" }
      }
    end
    assert_redirected_to cohort_path(cohort)
    assert_equal "Message could not be sent.", flash[:alert]
  end
end
