# A member's report of offensive content or behaviour. Reports aren't a model of
# their own: each one becomes a HelpRequest in the admin help desk inbox, linked
# back to the reported record through `reportable`, so admins triage them with
# the tools they already use.
class ContentReport
  include ActiveModel::Model

  REPORTABLE_TYPES = %w[
    Post PostComment GroupPost GroupPostComment FeedPost FeedPostComment DirectMessage User
  ].freeze

  REASON_LENGTH = 2000
  NO_REASON = "No reason provided."

  attr_accessor :reporter, :reportable, :reason

  def self.find_reportable(type, id)
    return unless type.in?(REPORTABLE_TYPES)

    type.constantize.find_by(id: id)
  end

  # The help request this report creates, or the reporter's existing open
  # report on the same item, so repeat clicks don't flood the inbox.
  def submit
    reporter.with_lock do
      if (report = open_report)
        report.with_lock do
          report.open? ? append_reason_to(report) : create_report
        end
      else
        create_report
      end
    end
  end

  def open_report
    reporter.help_requests.open.find_by(reportable: reportable)
  end

  def author
    reportable.is_a?(User) ? reportable : reportable.try(:user) || reportable.try(:sender)
  end

  def kind
    case reportable
    when User then "profile"
    when DirectMessage then "message"
    when PostComment, GroupPostComment, FeedPostComment then "comment"
    else "post"
    end
  end

  def subject
    "Report: #{kind}"
  end

  def path
    self.class.path_for(reportable)
  end

  # Where the reported item can be viewed.
  def self.path_for(record)
    helpers = Rails.application.routes.url_helpers
    case record
    when User then helpers.profile_path(record)
    when Post then helpers.cohort_post_path(record.cohort_id, record)
    when PostComment
      helpers.cohort_post_path(record.post.cohort_id, record.post_id,
                               reported_comment_id: record.id, anchor: ActionView::RecordIdentifier.dom_id(record))
    when GroupPost then helpers.group_group_post_path(record.group_id, record)
    when GroupPostComment
      helpers.group_group_post_path(record.group_post.group_id, record.group_post_id,
                                    reported_comment_id: record.id, anchor: ActionView::RecordIdentifier.dom_id(record))
    when FeedPost then helpers.feed_post_path(record)
    when FeedPostComment
      helpers.feed_post_path(record.feed_post_id,
                             reported_comment_id: record.id, anchor: ActionView::RecordIdentifier.dom_id(record))
    when DirectMessage then helpers.conversation_path(record.conversation_id)
    end
  end

  def self.path_for_help_request(help_request, viewer:)
    reportable = help_request.reportable
    if help_request.reportable_type == "DirectMessage"
      if viewer.admin? && help_request.open?
        Rails.application.routes.url_helpers.help_request_reported_direct_message_path(help_request)
      elsif reportable&.conversation&.participants&.exists?(id: viewer.id)
        path_for(reportable)
      end
    elsif reportable
      path_for(reportable)
    end
  end

  private

  def append_reason_to(report)
    return report if reason.blank?

    report.update!(body: "#{report.body}\n\nAdditional reason:\n#{reason.strip.truncate(REASON_LENGTH)}")
    report.notify_admins!
    report
  end

  def create_report
    report = reporter.help_requests.create!(reportable: reportable, subject: subject, body: body)
    if reportable.is_a?(DirectMessage)
      path = Rails.application.routes.url_helpers.help_request_reported_direct_message_path(report)
      report.update!(body: body(path))
    end
    report
  end

  def body(link = path)
    lines = []
    lines << "Link: #{link}" if link
    lines << (reason.present? ? "Reason:\n#{reason.strip.truncate(REASON_LENGTH)}" : NO_REASON)
    lines.join("\n\n")
  end
end
