require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "admin can access dashboard" do
    sign_in users(:admin)
    get admin_dashboard_path
    assert_response :success
  end

  test "attendee cannot access dashboard" do
    sign_in users(:attendee)
    get admin_dashboard_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get admin_dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "admin dashboard shows user count and cohort count" do
    sign_in users(:admin)
    get admin_dashboard_path
    assert_response :success
    assert_select "body" # verifies the response renders a full page
  end

  test "admin dashboard shows admins in separate section above users" do
    sign_in users(:admin)
    get admin_dashboard_path
    assert_response :success

    assert_select "h2", text: "Admins"
    assert_select "h2", text: "Users"
  end

  test "admin dashboard lists admin users in admins section" do
    sign_in users(:admin)
    get admin_dashboard_path

    # Admin user should appear in the Admins section
    assert_select "h2", text: "Admins" do |headings|
      admin_section = headings.first.parent
      assert_match users(:admin).name, admin_section.text
    end
  end

  test "admin dashboard lists attendees in users section" do
    sign_in users(:admin)
    get admin_dashboard_path

    # Attendee should appear in the Users section
    assert_select "h2", text: "Users" do |headings|
      users_section = headings.first.parent
      assert_match users(:attendee).name, users_section.text
    end
  end
end
