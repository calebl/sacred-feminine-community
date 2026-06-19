# Mirror the fixture defaults: every seeded user shares a known password and is
# treated as having accepted their invitation unless overridden (e.g. pending_invite).
users.defaults password: "password123", password_confirmation: "password123",
  invitation_accepted_at: -> { Time.current }
