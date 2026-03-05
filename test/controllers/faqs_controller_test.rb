require "test_helper"

class FaqsControllerTest < ActionDispatch::IntegrationTest
  # Index
  test "authenticated user can access faqs index" do
    sign_in users(:attendee)
    get faqs_path
    assert_response :success
    assert_match "How do I join a cohort?", response.body
  end

  test "admin sees new faq form on index" do
    sign_in users(:admin)
    get faqs_path
    assert_response :success
    assert_select "details summary", text: /New FAQ/
  end

  test "attendee does not see new faq form on index" do
    sign_in users(:attendee)
    get faqs_path
    assert_response :success
    assert_select "details summary", text: /New FAQ/, count: 0
  end

  test "index renders inside turbo frame" do
    sign_in users(:attendee)
    get faqs_path
    assert_select "turbo-frame#faqs_panel"
  end

  # Create
  test "admin can create faq" do
    sign_in users(:admin)
    assert_difference "Faq.count" do
      post faqs_path, params: {
        faq: { question: "New question?", answer: "New answer.", position: 0, active: true }
      }
    end
    assert_redirected_to faqs_path
  end

  test "attendee cannot create faq" do
    sign_in users(:attendee)
    assert_no_difference "Faq.count" do
      post faqs_path, params: {
        faq: { question: "Hacked?", answer: "Not allowed." }
      }
    end
    assert_redirected_to root_path
  end

  test "create with invalid params redirects with alert" do
    sign_in users(:admin)
    assert_no_difference "Faq.count" do
      post faqs_path, params: {
        faq: { question: "", answer: "" }
      }
    end
    assert_redirected_to faqs_path
    assert_equal "Question can't be blank and Answer can't be blank", flash[:alert]
  end

  # Edit
  test "admin can access edit faq form" do
    sign_in users(:admin)
    get edit_faq_path(faqs(:active_faq))
    assert_response :success
  end

  test "attendee cannot access edit faq form" do
    sign_in users(:attendee)
    get edit_faq_path(faqs(:active_faq))
    assert_redirected_to root_path
  end

  # Update
  test "admin can update faq" do
    sign_in users(:admin)
    patch faq_path(faqs(:active_faq)), params: {
      faq: { question: "Updated question?" }
    }
    assert_redirected_to faqs_path
    assert_equal "Updated question?", faqs(:active_faq).reload.question
  end

  test "attendee cannot update faq" do
    sign_in users(:attendee)
    patch faq_path(faqs(:active_faq)), params: {
      faq: { question: "Hacked?" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked?", faqs(:active_faq).reload.question
  end

  # Destroy
  test "admin can delete faq" do
    sign_in users(:admin)
    assert_difference "Faq.count", -1 do
      delete faq_path(faqs(:inactive_faq))
    end
    assert_redirected_to faqs_path
  end

  test "attendee cannot delete faq" do
    sign_in users(:attendee)
    assert_no_difference "Faq.count" do
      delete faq_path(faqs(:active_faq))
    end
    assert_redirected_to root_path
  end

  # Dashboard integration
  test "dashboard faqs tab renders turbo frame placeholder" do
    sign_in users(:attendee)
    get authenticated_root_path(tab: "faqs")
    assert_response :success
    assert_select "turbo-frame#faqs_panel[src='#{faqs_path}']"
  end
end
