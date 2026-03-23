# Coordinates are provided inline, so skip geocoding API calls.
User.skip_callback(:commit, :after, :enqueue_geocode)

users.defaults password: "password123", password_confirmation: "password123", invitation_accepted_at: -> { Time.current }
