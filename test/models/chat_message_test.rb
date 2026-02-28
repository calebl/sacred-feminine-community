require "test_helper"

class ChatMessageTest < ActiveSupport::TestCase
  test "requires body" do
    message = ChatMessage.new(cohort: cohorts(:kabul_retreat), user: users(:attendee))
    assert_not message.valid?
    assert_includes message.errors[:body], "can't be blank"
  end

  test "requires cohort" do
    message = ChatMessage.new(body: "Hello", user: users(:attendee))
    assert_not message.valid?
    assert_includes message.errors[:cohort], "must exist"
  end

  test "requires user" do
    message = ChatMessage.new(body: "Hello", cohort: cohorts(:kabul_retreat))
    assert_not message.valid?
    assert_includes message.errors[:user], "must exist"
  end

  test "valid with all attributes" do
    message = ChatMessage.new(
      body: "Hello everyone!",
      cohort: cohorts(:kabul_retreat),
      user: users(:attendee)
    )
    assert message.valid?
  end
end
