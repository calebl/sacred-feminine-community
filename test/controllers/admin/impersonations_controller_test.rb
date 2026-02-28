require "test_helper"

class Admin::ImpersonationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @attendee = users(:attendee)
  end

  # Create (start impersonation)

  test "admin can start impersonating a user" do
    sign_in @admin
    post admin_impersonation_path, params: { user_id: @attendee.id }
    assert_redirected_to authenticated_root_path
    assert_match "Now impersonating", flash[:notice]
  end

  test "attendee cannot start impersonation" do
    sign_in @attendee
    post admin_impersonation_path, params: { user_id: @admin.id }
    assert_redirected_to root_path
  end

  test "admin cannot impersonate themselves" do
    sign_in @admin
    post admin_impersonation_path, params: { user_id: @admin.id }
    assert_redirected_to admin_dashboard_path
    assert_equal "Cannot impersonate yourself.", flash[:alert]
  end

  test "admin cannot start impersonation while already impersonating" do
    # Create a second admin so current_user (the impersonated user) passes the policy check
    admin_two = User.create!(name: "Admin Two", email: "admin2@example.com", password: "password123", role: :admin)

    sign_in @admin
    # Start impersonating admin_two (who is also admin, so authorize passes)
    post admin_impersonation_path, params: { user_id: admin_two.id }
    assert_redirected_to authenticated_root_path

    # Try to start another impersonation — should be blocked by impersonating? check
    post admin_impersonation_path, params: { user_id: @attendee.id }
    assert_redirected_to admin_dashboard_path
    assert_equal "Already impersonating. Stop first.", flash[:alert]
  end

  # Destroy (stop impersonation)

  test "admin can stop impersonating" do
    sign_in @admin
    post admin_impersonation_path, params: { user_id: @attendee.id }

    delete admin_impersonation_path
    assert_redirected_to admin_dashboard_path
    assert_match "Stopped impersonating", flash[:notice]
  end

  test "unauthenticated user cannot impersonate" do
    post admin_impersonation_path, params: { user_id: @attendee.id }
    assert_redirected_to new_user_session_path
  end
end
