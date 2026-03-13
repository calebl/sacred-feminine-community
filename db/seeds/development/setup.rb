# Coordinates are provided inline, so skip geocoding API calls.
User.skip_callback(:commit, :after, :enqueue_geocode)

users.defaults do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.invitation_accepted_at = Time.current
end
