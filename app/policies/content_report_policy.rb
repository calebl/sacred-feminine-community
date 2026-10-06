class ContentReportPolicy < ApplicationPolicy
  # Members can report anything they can see that someone else wrote.
  def create?
    reportable = record.reportable
    return false if reportable.nil? || record.author.nil? || record.author == user

    case reportable
    when User then reportable.kept?
    when DirectMessage then reportable.conversation.participants.include?(user)
    when PostComment then visible_comment?(reportable, reportable.post) && Pundit.policy!(user, reportable.post).show?
    when GroupPostComment then visible_comment?(reportable, reportable.group_post) && Pundit.policy!(user, reportable.group_post).show?
    when FeedPostComment then visible_comment?(reportable, reportable.feed_post) && Pundit.policy!(user, reportable.feed_post).show?
    else !user.hides_content_from?(record.author) && Pundit.policy!(user, reportable).show?
    end
  end

  private

  def visible_comment?(comment, post)
    return false if user.hides_content_from?(post.user)

    while comment
      return false if user.hides_content_from?(comment.user)

      comment = comment.parent
    end
    true
  end
end
