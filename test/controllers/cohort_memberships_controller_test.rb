require "test_helper"

class CohortMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "admin can add member to cohort" do
    sign_in users(:admin)
    assert_difference "CohortMembership.count" do
      post cohort_cohort_memberships_path(cohorts(:bali_retreat)), params: {
        user_id: users(:attendee).id
      }
    end
    assert_redirected_to cohort_path(cohorts(:bali_retreat))
    assert cohorts(:bali_retreat).member?(users(:attendee))
  end

  test "admin can remove member from cohort" do
    sign_in users(:admin)
    membership = cohort_memberships(:attendee_in_kabul)
    assert_difference "CohortMembership.count", -1 do
      delete cohort_cohort_membership_path(cohorts(:kabul_retreat), membership)
    end
    assert_redirected_to cohort_path(cohorts(:kabul_retreat))
  end

  test "attendee cannot add members" do
    sign_in users(:attendee)
    assert_no_difference "CohortMembership.count" do
      post cohort_cohort_memberships_path(cohorts(:kabul_retreat)), params: {
        user_id: users(:attendee_two).id
      }
    end
    assert_redirected_to root_path
  end

  test "attendee cannot remove members" do
    sign_in users(:attendee)
    membership = cohort_memberships(:admin_in_kabul)
    assert_no_difference "CohortMembership.count" do
      delete cohort_cohort_membership_path(cohorts(:kabul_retreat), membership)
    end
    assert_redirected_to root_path
  end
end
