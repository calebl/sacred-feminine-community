conversation_participants.create :admin_in_convo,
  conversation: conversations.admin_attendee_convo, user: users.admin

conversation_participants.create :attendee_in_convo,
  conversation: conversations.admin_attendee_convo, user: users.attendee
