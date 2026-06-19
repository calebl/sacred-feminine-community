# Group#add_creator_as_member auto-creates a membership for each creator, so the
# creator memberships from the old fixtures (attendee in book_club, admin in
# yoga_group, attendee_two in reading_group) are created here implicitly. Only the
# non-creator memberships are added explicitly in group_memberships.rb.
groups.create :book_club,
  name: "Book Club", description: "A group for discussing books", creator: users.attendee

groups.create :yoga_group,
  name: "Yoga Circle", description: "Daily yoga practice and mindfulness", creator: users.admin

groups.create :reading_group,
  name: "Reading Group", description: "A members-only reading group", creator: users.attendee_two
