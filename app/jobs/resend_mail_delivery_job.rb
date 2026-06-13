# Used by Action Mailer's `deliver_later` (configured via
# `config.action_mailer.delivery_job`). Adds Resend 429 retry handling to the
# asynchronous mail path, e.g. Devise notifications sent from User.
class ResendMailDeliveryJob < ActionMailer::MailDeliveryJob
  include ResendRateLimitRetryable
end
