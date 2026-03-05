require "test_helper"

class Admin::AnnouncementsControllerTest < ActionDispatch::IntegrationTest
  # Index
  test "admin can list announcements" do
    sign_in users(:admin)
    get admin_announcements_path
    assert_response :success
    assert_match "Welcome to the Community", response.body
  end

  test "attendee cannot list announcements" do
    sign_in users(:attendee)
    get admin_announcements_path
    assert_redirected_to root_path
  end

  # New
  test "admin can access new announcement form" do
    sign_in users(:admin)
    get new_admin_announcement_path
    assert_response :success
  end

  test "attendee cannot access new announcement form" do
    sign_in users(:attendee)
    get new_admin_announcement_path
    assert_redirected_to root_path
  end

  # Create
  test "admin can create announcement" do
    sign_in users(:admin)
    assert_difference "Announcement.count" do
      post admin_announcements_path, params: {
        announcement: { title: "New Update", body: "Something important", active: true }
      }
    end
    assert_redirected_to admin_announcements_path
  end

  test "attendee cannot create announcement" do
    sign_in users(:attendee)
    assert_no_difference "Announcement.count" do
      post admin_announcements_path, params: {
        announcement: { title: "Hacked", body: "Not allowed" }
      }
    end
    assert_redirected_to root_path
  end

  # Edit
  test "admin can access edit announcement form" do
    sign_in users(:admin)
    get edit_admin_announcement_path(announcements(:active_announcement))
    assert_response :success
  end

  # Update
  test "admin can update announcement" do
    sign_in users(:admin)
    patch admin_announcement_path(announcements(:active_announcement)), params: {
      announcement: { title: "Updated Title" }
    }
    assert_redirected_to admin_announcements_path
    assert_equal "Updated Title", announcements(:active_announcement).reload.title
  end

  test "attendee cannot update announcement" do
    sign_in users(:attendee)
    patch admin_announcement_path(announcements(:active_announcement)), params: {
      announcement: { title: "Hacked" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked", announcements(:active_announcement).reload.title
  end

  # Destroy
  test "admin can delete announcement" do
    sign_in users(:admin)
    assert_difference "Announcement.count", -1 do
      delete admin_announcement_path(announcements(:inactive_announcement))
    end
    assert_redirected_to admin_announcements_path
  end

  test "attendee cannot delete announcement" do
    sign_in users(:attendee)
    assert_no_difference "Announcement.count" do
      delete admin_announcement_path(announcements(:active_announcement))
    end
    assert_redirected_to root_path
  end

  # Dashboard creation
  test "admin can create announcement from dashboard" do
    sign_in users(:admin)
    assert_difference "Announcement.count" do
      post admin_announcements_path, params: {
        announcement: { title: "Dashboard Announcement", body: "Created from dashboard", active: true },
        source: "dashboard"
      }
    end
    assert_redirected_to authenticated_root_path
  end

  test "admin sees new announcement form on dashboard" do
    sign_in users(:admin)
    get authenticated_root_path
    assert_response :success
    assert_select "details summary", text: /New Announcement/
  end

  test "attendee does not see new announcement form on dashboard" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
    assert_select "details summary", count: 0
  end

  test "failed dashboard creation redirects back to dashboard with alert" do
    sign_in users(:admin)
    assert_no_difference "Announcement.count" do
      post admin_announcements_path, params: {
        announcement: { title: "", body: "" },
        source: "dashboard"
      }
    end
    assert_redirected_to authenticated_root_path
    assert_equal "Title can't be blank and Body can't be blank", flash[:alert]
  end

  # Dashboard display
  test "announcement is visible on dashboard for all users" do
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
    assert_match "Welcome to the Community", response.body
  end

  test "dashboard works with no active announcement" do
    Announcement.update_all(active: false)
    sign_in users(:attendee)
    get authenticated_root_path
    assert_response :success
  end
end
