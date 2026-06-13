require "test_helper"

class ResendRateLimitRetryableTest < ActiveJob::TestCase
  # Minimal job that always hits a Resend 429, so we can observe retry behavior.
  class DummyResendJob < ApplicationJob
    def perform(retry_after:)
      headers = retry_after ? { "retry-after" => retry_after.to_s } : {}
      raise Resend::Error::RateLimitExceededError.new("Too many requests", 429, headers)
    end
  end

  test "retries honoring Resend's retry-after header" do
    freeze_time do
      assert_enqueued_with(job: DummyResendJob, at: 7.seconds.from_now) do
        DummyResendJob.new(retry_after: 7).perform_now
      end
    end
  end

  test "falls back to the default wait when no retry-after header is present" do
    freeze_time do
      assert_enqueued_with(job: DummyResendJob, at: ResendRateLimitRetryable::FALLBACK_WAIT.from_now) do
        DummyResendJob.new(retry_after: nil).perform_now
      end
    end
  end

  test "stops retrying and re-raises after MAX_ATTEMPTS" do
    job = DummyResendJob.new(retry_after: 1)
    job.executions = ResendRateLimitRetryable::MAX_ATTEMPTS - 1

    assert_no_enqueued_jobs do
      assert_raises(Resend::Error::RateLimitExceededError) { job.perform_now }
    end
  end

  test "the asynchronous mail delivery job retries on Resend rate limits" do
    assert_includes ResendMailDeliveryJob.ancestors, ResendRateLimitRetryable
    assert_equal "ResendMailDeliveryJob", ApplicationMailer.delivery_job.to_s
  end
end
