users.create :admin,
  name: "Admin User", email: "admin@sacredfeminine.com", role: :admin,
  city: "Los Angeles", state: "California", country: "United States", show_on_map: true

users.create :attendee,
  name: "Jane Attendee", email: "jane@example.com", role: :attendee,
  city: "Paris", country: "France", show_on_map: true

users.create :attendee_two,
  name: "Sarah Member", email: "sarah@example.com", role: :attendee,
  city: "Tokyo", country: "Japan", show_on_map: false

users.create :admin_two,
  name: "Admin Two", email: "admin2@sacredfeminine.com", role: :admin,
  city: "Berlin", country: "Germany", show_on_map: true

users.create :pending_invite,
  name: "Pending User", email: "pending@example.com",
  invitation_token: Devise.token_generator.generate(User, :invitation_token).last,
  invitation_created_at: Time.current, invitation_sent_at: Time.current,
  invitation_accepted_at: nil
