require "test_helper"

class CohortsControllerTest < ActionDispatch::IntegrationTest
  # Index
  test "attendee sees only their cohorts" do
    sign_in users(:attendee)
    get cohorts_path
    assert_response :success
    assert_match "Kabul Retreat", response.body
    assert_no_match "Bali Retreat", response.body
  end

  test "admin sees all cohorts" do
    sign_in users(:admin)
    get cohorts_path
    assert_response :success
    assert_match "Kabul Retreat", response.body
    assert_match "Bali Retreat", response.body
  end

  # Show
  test "member can view their cohort" do
    sign_in users(:attendee)
    get cohort_path(cohorts(:kabul_retreat))
    assert_response :success
  end

  test "non-member cannot view cohort" do
    sign_in users(:attendee_two)
    get cohort_path(cohorts(:kabul_retreat))
    assert_redirected_to root_path
  end

  test "admin can view any cohort" do
    sign_in users(:admin)
    get cohort_path(cohorts(:bali_retreat))
    assert_response :success
  end

  # Create
  test "admin can create cohort" do
    sign_in users(:admin)
    assert_difference "Cohort.count" do
      post cohorts_path, params: {
        cohort: { name: "New Retreat", retreat_location: "Costa Rica", retreat_start_date: "2026-06-01", retreat_end_date: "2026-06-04" }
      }
    end
    assert_redirected_to cohort_path(Cohort.last)
  end

  test "attendee cannot create cohort" do
    sign_in users(:attendee)
    get new_cohort_path
    assert_redirected_to root_path
  end

  # Update
  test "admin can update cohort" do
    sign_in users(:admin)
    patch cohort_path(cohorts(:kabul_retreat)), params: {
      cohort: { name: "Updated Name" }
    }
    assert_redirected_to cohort_path(cohorts(:kabul_retreat))
    assert_equal "Updated Name", cohorts(:kabul_retreat).reload.name
  end

  test "attendee cannot update cohort" do
    sign_in users(:attendee)
    patch cohort_path(cohorts(:kabul_retreat)), params: {
      cohort: { name: "Hacked" }
    }
    assert_redirected_to root_path
    assert_not_equal "Hacked", cohorts(:kabul_retreat).reload.name
  end

  # Destroy (soft-delete)
  test "admin can archive cohort" do
    sign_in users(:admin)
    cohort = cohorts(:bali_retreat)

    assert_no_difference "Cohort.count" do
      delete cohort_path(cohort)
    end

    assert_redirected_to cohorts_path
    assert_equal "Cohort archived.", flash[:notice]
    assert cohort.reload.discarded?
  end

  test "attendee cannot archive cohort" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)

    delete cohort_path(cohort)

    assert_redirected_to root_path
    assert_not cohort.reload.discarded?
  end

  test "archived cohort is not accessible" do
    sign_in users(:admin)
    cohort = cohorts(:bali_retreat)
    cohort.discard

    get cohort_path(cohort)
    assert_response :not_found
  end

  # Mark as read
  test "show marks group chat as read" do
    sign_in users(:attendee)
    cohort = cohorts(:kabul_retreat)
    membership = cohort.cohort_memberships.find_by(user: users(:attendee))
    assert_nil membership.last_read_at

    get cohort_path(cohort)

    membership.reload
    assert_not_nil membership.last_read_at
  end

  # Image removal
  test "admin can remove header image" do
    sign_in users(:admin)
    cohort = cohorts(:kabul_retreat)
    cohort.header_image.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    assert cohort.header_image.attached?

    patch cohort_path(cohort), params: {
      cohort: { remove_header_image: "1" }
    }
    assert_redirected_to cohort_path(cohort)
    assert_not cohort.reload.header_image.attached?
  end

  # Edit
  test "admin can access edit form" do
    sign_in users(:admin)
    get edit_cohort_path(cohorts(:kabul_retreat))
    assert_response :success
  end

  # Create with invalid params
  test "admin sees form again on invalid create" do
    sign_in users(:admin)
    assert_no_difference "Cohort.count" do
      post cohorts_path, params: { cohort: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  # Update with invalid params
  test "admin sees form again on invalid update" do
    sign_in users(:admin)
    patch cohort_path(cohorts(:kabul_retreat)), params: {
      cohort: { name: "" }
    }
    assert_response :unprocessable_entity
    assert_not_equal "", cohorts(:kabul_retreat).reload.name
  end
end
