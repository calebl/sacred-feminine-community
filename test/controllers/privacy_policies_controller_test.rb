require "test_helper"

class PrivacyPoliciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_contact_email = ENV["CONTACT_EMAIL"]
    ENV["CONTACT_EMAIL"] = "contact@example.test"
  end

  teardown do
    ENV["CONTACT_EMAIL"] = @original_contact_email
  end

  test "is readable while signed out" do
    get privacy_policy_path
    assert_response :success
    assert_select "h1", text: "Privacy Policy"
    assert_select "a[href='mailto:contact@example.test']"
    assert_select "p", text: /only remaining admin must make someone else an admin/
  end

  test "omits the public email contact when it is not configured" do
    ENV.delete("CONTACT_EMAIL")

    get privacy_policy_path

    assert_response :success
    assert_select "a[href^='mailto:']", count: 0
    assert_select "footer a", text: "Contact Us", count: 0
    assert_select "p", text: /Members can reach the admins through Help/
  end

  test "is readable while signed in" do
    sign_in users.attendee
    get privacy_policy_path
    assert_response :success
  end

  test "sign-in page links to the privacy policy" do
    get new_user_session_path
    assert_select "a[href='#{privacy_policy_path}']"
  end

  test "signed-in pages have a privacy and contact footer" do
    sign_in users.attendee
    get feed_posts_path
    assert_select "footer a[href='#{privacy_policy_path}']"
    assert_select "footer a[href='#{new_help_request_path}']", text: "Contact Us"
  end
end
