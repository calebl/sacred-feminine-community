require "test_helper"

class ConversationPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
    @attendee_two = users(:attendee_two)
    @conversation = conversations(:admin_attendee_convo)
  end

  test "participant can view conversation" do
    assert ConversationPolicy.new(@admin, @conversation).show?
    assert ConversationPolicy.new(@attendee, @conversation).show?
  end

  test "non-participant cannot view conversation" do
    assert_not ConversationPolicy.new(@attendee_two, @conversation).show?
  end

  test "any user can create a conversation" do
    assert ConversationPolicy.new(@admin, Conversation.new).create?
    assert ConversationPolicy.new(@attendee, Conversation.new).create?
  end

  test "scope returns only user's conversations" do
    scope = ConversationPolicy::Scope.new(@admin, Conversation).resolve
    assert_includes scope, @conversation

    scope = ConversationPolicy::Scope.new(@attendee, Conversation).resolve
    assert_includes scope, @conversation

    scope = ConversationPolicy::Scope.new(@attendee_two, Conversation).resolve
    assert_not_includes scope, @conversation
  end
end
