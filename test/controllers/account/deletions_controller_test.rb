require "test_helper"

class Account::DeletionsControllerTest < ActionDispatch::IntegrationTest
  test "shows the warning and confirmation form" do
    sign_in users.attendee
    get new_account_deletion_path
    assert_response :success
    assert_select "p", text: /permanently deletes your account/
    assert_select "input[name='user[current_password]']"
    assert_select "input[name='user[confirmation]']"
  end

  test "requires sign in" do
    get new_account_deletion_path
    assert_redirected_to new_user_session_path
  end

  test "deletes the account with the right password and confirmation" do
    user = users.attendee
    sign_in user

    assert_difference -> { User.count }, -1 do
      post account_deletion_path, params: { user: { current_password: "password123", confirmation: "DELETE" } }
    end

    assert_redirected_to new_user_session_path
    assert_not User.exists?(user.id)
    get authenticated_root_path
    assert_redirected_to new_user_session_path
  end

  test "rejects a wrong password" do
    sign_in users.attendee

    assert_no_difference -> { User.count } do
      post account_deletion_path, params: { user: { current_password: "wrong", confirmation: "DELETE" } }
    end

    assert_response :unprocessable_entity
    assert_select "p", text: /Current password is incorrect/
  end

  test "rejects a missing confirmation word" do
    sign_in users.attendee

    assert_no_difference -> { User.count } do
      post account_deletion_path, params: { user: { current_password: "password123", confirmation: "delete me" } }
    end

    assert_response :unprocessable_entity
    assert_select "p", text: /Type DELETE to confirm/
  end

  test "the only admin cannot delete their account" do
    users.admin_two.update_columns(role: User.roles[:attendee])
    sign_in users.admin

    assert_no_difference -> { User.count } do
      post account_deletion_path, params: { user: { current_password: "password123", confirmation: "DELETE" } }
    end

    assert User.exists?(users.admin.id)
  end

  test "profile settings link to account deletion" do
    sign_in users.attendee
    get edit_profile_path(users.attendee)
    assert_select "a[href='#{new_account_deletion_path}']", text: "Delete my account"
  end
end
