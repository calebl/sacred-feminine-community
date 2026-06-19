# Creator memberships are auto-created by Group#add_creator_as_member (see groups.rb).
# These are the additional, non-creator memberships from the old fixtures.
group_memberships.create :admin_in_book_club, user: users.admin, group: groups.book_club
group_memberships.create :attendee_in_yoga, user: users.attendee, group: groups.yoga_group
