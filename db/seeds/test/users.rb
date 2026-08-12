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

# Cohort gender filtering: male_member belongs to a men's cohort, the other two
# carry a restrictive cohort_gender_privacy setting. All three stay off the map
# so existing map pin counts hold; tests that need a pin opt in explicitly.
users.create :male_member,
  name: "Michael Member", email: "michael@example.com", role: :attendee,
  city: "Denver", country: "United States", show_on_map: false

users.create :women_only_member,
  name: "Willa Member", email: "willa@example.com", role: :attendee,
  city: "Lisbon", country: "Portugal", show_on_map: false,
  cohort_gender_privacy: :women_only

# men_only is only valid for a male cohort member, so it is set in
# cohort_memberships.rb once this user is in the men's cohort.
users.create :men_only_member,
  name: "Marcus Member", email: "marcus@example.com", role: :attendee,
  city: "Oslo", country: "Norway", show_on_map: false
