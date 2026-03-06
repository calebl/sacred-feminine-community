require "test_helper"

class PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  test "create stores a new push subscription" do
    sign_in @admin

    assert_difference "PushSubscription.count" do
      post push_subscriptions_path, params: {
        push_subscription: {
          endpoint: "https://push.example.com/new-endpoint",
          p256dh_key: "new_p256dh_key",
          auth_key: "new_auth_key"
        }
      }, as: :json
    end

    assert_response :created
    sub = PushSubscription.last
    assert_equal @admin, sub.user
    assert_equal "https://push.example.com/new-endpoint", sub.endpoint
  end

  test "create updates existing subscription by endpoint" do
    sign_in @admin
    existing = push_subscriptions(:admin_sub)

    assert_no_difference "PushSubscription.count" do
      post push_subscriptions_path, params: {
        push_subscription: {
          endpoint: existing.endpoint,
          p256dh_key: "updated_p256dh",
          auth_key: "updated_auth"
        }
      }, as: :json
    end

    assert_response :created
    existing.reload
    assert_equal "updated_p256dh", existing.p256dh_key
    assert_equal "updated_auth", existing.auth_key
  end

  test "destroy removes subscription by endpoint" do
    sign_in @admin
    sub = push_subscriptions(:admin_sub)

    assert_difference "PushSubscription.count", -1 do
      delete push_subscription_path(sub), as: :json
    end

    assert_response :ok
  end

  test "unauthenticated user cannot create subscription" do
    post push_subscriptions_path, params: {
      push_subscription: {
        endpoint: "https://push.example.com/unauth",
        p256dh_key: "key",
        auth_key: "auth"
      }
    }, as: :json

    assert_response :unauthorized
  end

  test "unauthenticated user cannot destroy subscription" do
    sub = push_subscriptions(:admin_sub)
    delete push_subscription_path(sub), as: :json
    assert_response :unauthorized
  end
end
