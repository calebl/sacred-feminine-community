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

  attr_accessor :reporter, :reportable, :reason

  def self.find_reportable(type, id)
    return unless type.in?(REPORTABLE_TYPES)

    type.constantize.find_by(id: id)
  end

  # The help request this report creates, or the reporter's existing open
  # report on the same item, so repeat clicks don't flood the inbox.
  def submit
    open_report || reporter.help_requests.create!(reportable: reportable, subject: subject, body: body)
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

  def body
    lines = [ "#{reporter.name} reported a #{kind} by #{author.name} (profile: #{self.class.path_for(author)})." ]
    lines << "Link: #{path}" if path
    if (text = reportable.try(:body)).present?
      lines << "Reported text:\n#{text.gsub(Mentionable::MENTION_PATTERN) { "@#{$1}" }.truncate(EXCERPT_LENGTH)}"
    end
    lines << "Reason:\n#{reason.strip.truncate(REASON_LENGTH)}" if reason.present?
    lines.join("\n\n")
  end
end
