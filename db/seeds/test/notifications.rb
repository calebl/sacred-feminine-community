notifications.create :admin_new_member,
  user: users.admin, actor: users.attendee, event_type: "new_member",
  title: "New Member", body: "Jane Attendee has joined the community",
  path: "/profiles/#{users.attendee.id}", read_at: nil

notifications.create :admin_read_notification,
  user: users.admin, actor: users.attendee_two, event_type: "new_member",
  title: "New Member", body: "Sarah Member has joined the community",
  path: "/profiles/#{users.attendee_two.id}", read_at: Time.current
