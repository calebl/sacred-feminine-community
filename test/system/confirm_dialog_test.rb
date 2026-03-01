require "application_system_test_case"

class ConfirmDialogTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @cohort = cohorts(:kabul_retreat)
    sign_in @admin
  end

  test "shows custom confirm dialog on destructive action" do
    visit edit_cohort_path(@cohort)

    click_on "Delete Cohort"

    assert_selector "dialog[open]"
    assert_text "Are you sure?"
    assert_text "This will delete the cohort and all its messages."
  end

  test "confirming the dialog proceeds with the action" do
    visit edit_cohort_path(@cohort)

    click_on "Delete Cohort"

    within("dialog[open]") do
      click_on "Confirm"
    end

    assert_current_path cohorts_path
  end

  test "cancelling the dialog prevents the action" do
    visit edit_cohort_path(@cohort)

    click_on "Delete Cohort"

    within("dialog[open]") do
      click_on "Cancel"
    end

    assert_no_selector "dialog[open]"
    assert_current_path edit_cohort_path(@cohort)
  end

  test "escape key dismisses the dialog" do
    visit edit_cohort_path(@cohort)

    click_on "Delete Cohort"
    assert_selector "dialog[open]"

    send_keys :escape

    assert_no_selector "dialog[open]"
    assert_current_path edit_cohort_path(@cohort)
  end
end
