# A member's report of offensive content or behaviour. Reports aren't a model of
# their own: each one becomes a HelpRequest in the admin help desk inbox, linked
# back to the reported record through `reportable`, so admins triage them with
# the tools they already use.
class ContentReport
  include ActiveModel::Model

  REPORTABLE_TYPES = %w[
    Post PostComment GroupPost GroupPostComment FeedPost FeedPostComment DirectMessage User
  ].freeze

  EXCERPT_LENGTH = 500
  REASON_LENGTH = 2000
  DELETED_CONTENT_MARKER = "Content deleted by its author."

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

  def self.redact_authored_by!(author)
    reportable_ids_by_type(author).each do |type, ids|
      HelpRequest.where(reportable_type: type, reportable_id: ids)
        .update_all(body: DELETED_CONTENT_MARKER, reported_snapshot: nil)
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
    "Report: #{kind} by #{author.name}"
  end

  def path
    self.class.path_for(reportable)
  end

  # Where an admin goes to see the reported item. Direct messages have no page
  # an admin can open, so their text is copied into the report instead.
  def self.path_for(record)
    helpers = Rails.application.routes.url_helpers
    case record
    when User then helpers.profile_path(record)
    when Post then helpers.cohort_post_path(record.cohort_id, record)
    when PostComment then helpers.cohort_post_path(record.post.cohort_id, record.post_id)
    when GroupPost then helpers.group_group_post_path(record.group_id, record)
    when GroupPostComment then helpers.group_group_post_path(record.group_post.group_id, record.group_post_id)
    when FeedPost then helpers.feed_post_path(record)
    when FeedPostComment then helpers.feed_post_path(record.feed_post_id)
    end
  end

  private

  def self.reportable_ids_by_type(author)
    REPORTABLE_TYPES.to_h do |type|
      records = type.constantize
      ids = if records == User
        [ author.id ]
      elsif records == DirectMessage
        records.where(sender_id: author.id).ids
      else
        records.where(user_id: author.id).ids
      end
      [ type, ids ]
    end
  end
  private_class_method :reportable_ids_by_type

  def append_reason_to(report)
    return report if reason.blank?

    report.update!(body: "#{report.body}\n\nAdditional reason:\n#{reason.strip.truncate(REASON_LENGTH)}")
    report
  end

  def create_report
    reporter.help_requests.create!(
      reportable: reportable,
      subject: subject,
      body: body,
      reported_snapshot: reported_snapshot
    )
  end

  def reported_snapshot
    return unless reportable.is_a?(DirectMessage)

    reportable.body.gsub(Mentionable::MENTION_PATTERN) { "@#{$1}" }.truncate(EXCERPT_LENGTH)
  end

  def body
    lines = [ "#{reporter.name} reported a #{kind} by #{author.name} (profile: #{self.class.path_for(author)})." ]
    lines << "Link: #{path}" if path
    if !reportable.is_a?(DirectMessage) && (text = reportable.try(:body)).present?
      lines << "Reported text:\n#{text.gsub(Mentionable::MENTION_PATTERN) { "@#{$1}" }.truncate(EXCERPT_LENGTH)}"
    end
    lines << "Reason:\n#{reason.strip.truncate(REASON_LENGTH)}" if reason.present?
    lines.join("\n\n")
  end
end
