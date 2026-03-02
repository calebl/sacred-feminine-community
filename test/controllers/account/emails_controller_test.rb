require "test_helper"

class Account::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can view email edit page" do
    sign_in users(:attendee)
    get edit_account_email_path
    assert_response :success
    assert_select "input[type='email']"
  end

  test "unauthenticated user is redirected to sign in" do
    get edit_account_email_path
    assert_redirected_to new_user_session_path
  end

  test "shows current email on edit page" do
    user = users(:attendee)
    sign_in user
    get edit_account_email_path
    assert_response :success
    assert_includes response.body, user.email
  end

  test "user can update email with correct password" do
    user = users(:attendee)
    sign_in user
    patch account_email_path, params: {
      user: { email: "newemail@example.com", current_password: "password123" }
    }
    assert_redirected_to edit_profile_path(user)
    assert_equal "newemail@example.com", user.reload.email
  end

  test "user cannot update email with wrong password" do
    user = users(:attendee)
    sign_in user
    original_email = user.email
    patch account_email_path, params: {
      user: { email: "newemail@example.com", current_password: "wrongpassword" }
    }
    assert_response :unprocessable_entity
    assert_equal original_email, user.reload.email
  end

  test "user cannot update email to invalid format" do
    user = users(:attendee)
    sign_in user
    original_email = user.email
    patch account_email_path, params: {
      user: { email: "not-an-email", current_password: "password123" }
    }
    assert_response :unprocessable_entity
    assert_equal original_email, user.reload.email
  end

  test "user cannot update email to existing email" do
    user = users(:attendee)
    sign_in user
    patch account_email_path, params: {
      user: { email: users(:admin).email, current_password: "password123" }
    }
    assert_response :unprocessable_entity
  end
end
