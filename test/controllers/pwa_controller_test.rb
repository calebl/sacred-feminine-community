require "test_helper"

class PwaControllerTest < ActionDispatch::IntegrationTest
  test "manifest returns success with JSON content type" do
    get pwa_manifest_path(format: :json)
    assert_response :success
    assert_match "application/json", response.content_type
  end

  test "manifest contains expected icon entries" do
    get pwa_manifest_path(format: :json)
    manifest = JSON.parse(response.body)
    assert manifest["icons"].any? { |icon| icon["src"].include?("icon-192") }
    assert manifest["icons"].any? { |icon| icon["src"].include?("icon-512") }
  end

  test "service worker returns success with JavaScript content type" do
    get pwa_service_worker_path(format: :js)
    assert_response :success
    assert_match "text/javascript", response.content_type
  end

  test "service worker contains cache configuration" do
    get pwa_service_worker_path(format: :js)
    assert_includes response.body, "sacred-feminine-"
    assert_includes response.body, "CACHE_NAME"
  end
end
