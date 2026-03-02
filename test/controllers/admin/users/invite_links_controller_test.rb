require "test_helper"

class Admin::Users::InviteLinksControllerTest < ActionDispatch::IntegrationTest
  test "admin can generate invite link for pending user" do
    sign_in users(:admin)
    pending_user = users(:pending_invite)

    post admin_user_invite_link_path(pending_user), headers: { "Accept" => "application/json" }
    assert_response :success

    json = JSON.parse(response.body)
    assert json["url"].include?("invitation_token=")
  end

  test "attendee cannot generate invite link" do
    sign_in users(:attendee)

    post admin_user_invite_link_path(users(:pending_invite)), headers: { "Accept" => "application/json" }
    assert_redirected_to root_path
  end

  test "unauthenticated user cannot generate invite link" do
    post admin_user_invite_link_path(users(:pending_invite)), headers: { "Accept" => "application/json" }
    assert_response :unauthorized
  end
end
