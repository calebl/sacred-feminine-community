# Retries a job when Resend rate-limits us (HTTP 429).
#
# Resend reports how long to wait via the `retry-after` response header, which
# the gem exposes as RateLimitExceededError#retry_after (seconds). We honor that
# value so retries line up with when capacity actually frees up, falling back to
# a short delay when the header is absent. After MAX_ATTEMPTS the error is
# re-raised so the job lands in Solid Queue's failed executions.
module ResendRateLimitRetryable
  extend ActiveSupport::Concern

  MAX_ATTEMPTS = 5
  FALLBACK_WAIT = 5.seconds

  included do
    rescue_from Resend::Error::RateLimitExceededError do |error|
      raise error if executions >= MAX_ATTEMPTS

      retry_job(wait: error.retry_after&.seconds || FALLBACK_WAIT)
    end
  end
end
