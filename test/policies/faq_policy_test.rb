require "test_helper"

class FaqPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users.admin
    @attendee = users.attendee
    @faq = faqs.active_faq
  end

  test "anyone can view the FAQ index" do
    assert FaqPolicy.new(@admin, Faq).index?
    assert FaqPolicy.new(@attendee, Faq).index?
  end

  test "admin can create FAQs" do
    assert FaqPolicy.new(@admin, Faq.new).create?
  end

  test "attendee cannot create FAQs" do
    assert_not FaqPolicy.new(@attendee, Faq.new).create?
  end

  test "admin can edit FAQs" do
    assert FaqPolicy.new(@admin, @faq).edit?
  end

  test "attendee cannot edit FAQs" do
    assert_not FaqPolicy.new(@attendee, @faq).edit?
  end

  test "admin can update FAQs" do
    assert FaqPolicy.new(@admin, @faq).update?
  end

  test "attendee cannot update FAQs" do
    assert_not FaqPolicy.new(@attendee, @faq).update?
  end

  test "admin can destroy FAQs" do
    assert FaqPolicy.new(@admin, @faq).destroy?
  end

  test "attendee cannot destroy FAQs" do
    assert_not FaqPolicy.new(@attendee, @faq).destroy?
  end

  test "scope returns all FAQs" do
    scope = FaqPolicy::Scope.new(@attendee, Faq).resolve
    assert_equal Faq.count, scope.count
  end
end
