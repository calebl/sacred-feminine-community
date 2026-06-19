help_requests.create :open_request,
  subject: "Cannot access my cohort",
  body: "I was added to the Spring 2026 cohort but I cannot see it on my dashboard.",
  status: :open, user: users.attendee

help_requests.create :closed_request,
  subject: "How do I change my avatar?",
  body: "I want to update my profile photo but cannot find the option.",
  status: :closed, user: users.attendee

help_requests.create :another_request,
  subject: "Map not loading",
  body: "The interactive map page shows a blank area for me.",
  status: :open, user: users.attendee_two
