require "test_helper"

class Account::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can view password edit page" do
    sign_in users(:attendee)
    get edit_account_password_path
    assert_response :success
  end

  test "unauthenticated user is redirected to sign in" do
    get edit_account_password_path
    assert_redirected_to new_user_session_path
  end

  test "user can update password with correct current password" do
    user = users(:attendee)
    sign_in user
    patch account_password_path, params: {
      user: {
        current_password: "password123",
        password: "newsecurepassword",
        password_confirmation: "newsecurepassword"
      }
    }
    assert_redirected_to edit_account_password_path
    assert user.reload.valid_password?("newsecurepassword")
  end

  test "user cannot update password with wrong current password" do
    user = users(:attendee)
    sign_in user
    patch account_password_path, params: {
      user: {
        current_password: "wrongpassword",
        password: "newsecurepassword",
        password_confirmation: "newsecurepassword"
      }
    }
    assert_response :unprocessable_entity
    assert user.reload.valid_password?("password123")
  end

  test "user cannot update password when confirmation does not match" do
    user = users(:attendee)
    sign_in user
    patch account_password_path, params: {
      user: {
        current_password: "password123",
        password: "newsecurepassword",
        password_confirmation: "differentpassword"
      }
    }
    assert_response :unprocessable_entity
    assert user.reload.valid_password?("password123")
  end

  test "user cannot set password shorter than minimum length" do
    user = users(:attendee)
    sign_in user
    patch account_password_path, params: {
      user: {
        current_password: "password123",
        password: "short",
        password_confirmation: "short"
      }
    }
    assert_response :unprocessable_entity
    assert user.reload.valid_password?("password123")
  end

  test "user remains signed in after password change" do
    user = users(:attendee)
    sign_in user
    patch account_password_path, params: {
      user: {
        current_password: "password123",
        password: "newsecurepassword",
        password_confirmation: "newsecurepassword"
      }
    }
    assert_redirected_to edit_account_password_path
    get authenticated_root_path
    assert_response :success
  end
end
