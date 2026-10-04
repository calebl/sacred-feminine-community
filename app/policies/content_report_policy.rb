class ContentReportPolicy < ApplicationPolicy
  # Members can report anything they can see that someone else wrote.
  def create?
    reportable = record.reportable
    return false if reportable.nil? || record.author.nil? || record.author == user

    case reportable
    when User then reportable.kept?
    when DirectMessage then reportable.conversation.participants.include?(user)
    when PostComment then Pundit.policy!(user, reportable.post).show?
    when GroupPostComment then Pundit.policy!(user, reportable.group_post).show?
    when FeedPostComment then Pundit.policy!(user, reportable.feed_post).show?
    else Pundit.policy!(user, reportable).show?
    end
  end
end
