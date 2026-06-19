help_request_replies.create :admin_reply,
  body: "I have added you to the cohort. Please try refreshing your dashboard.",
  help_request: help_requests.open_request, user: users.admin

help_request_replies.create :attendee_followup,
  body: "Thank you, it works now!",
  help_request: help_requests.open_request, user: users.attendee
