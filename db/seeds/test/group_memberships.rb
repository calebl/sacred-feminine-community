# Creator memberships are auto-created by Group#add_creator_as_member (see groups.rb).
# These are the additional, non-creator memberships from the old fixtures.
group_memberships.create :admin_in_book_club, user: users.admin, group: groups.book_club
group_memberships.create :attendee_in_yoga, user: users.attendee, group: groups.yoga_group
group_memberships.create :male_member_in_book_club, user: users.male_member, group: groups.book_club
group_memberships.create :women_only_member_in_book_club, user: users.women_only_member, group: groups.book_club
group_memberships.create :men_only_member_in_book_club, user: users.men_only_member, group: groups.book_club
