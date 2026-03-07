module Mentionable
  extend ActiveSupport::Concern

  MENTION_PATTERN = /@\[([^\]]+)\]\((\d+)\)/

  CONTEXT_MAP = {
    "Post" => :cohort,
    "PostComment" => :cohort,
    "GroupPost" => :group,
    "GroupPostComment" => :group,
    "FeedPost" => :feed,
    "FeedPostComment" => :feed,
    "DirectMessage" => :dm
  }.freeze

  included do
    has_many :mentions, as: :mentionable, dependent: :destroy
    after_create_commit :extract_mentions
    after_update_commit :re_extract_mentions, if: :saved_change_to_body?
  end

  private

  def mention_context
    CONTEXT_MAP[self.class.name]
  end

  def extract_mentions
    return if body.blank?

    mentioned_user_ids = body.scan(MENTION_PATTERN).map { |_name, id| id.to_i }.uniq
    return if mentioned_user_ids.empty?

    author = mention_author
    context = mention_context
    valid_users = User.active_users.where(id: mentioned_user_ids).where.not(id: author.id)

    valid_users.find_each do |user|
      next unless user.accepts_mentions_in?(context)
      mentions.create(user: user, mentioner: author)
      CreateNotificationJob.perform_later(
        user_id: user.id,
        actor_id: author.id,
        event_type: "mention",
        title: "#{author.name} mentioned you",
        body: mention_notification_body,
        path: mention_notification_path,
        notifiable_type: self.class.name,
        notifiable_id: id
      )
    end
  end

  def re_extract_mentions
    mentions.destroy_all
    extract_mentions
  end

  def mention_author
    respond_to?(:sender) ? sender : user
  end

  def mention_notification_path
    case self
    when DirectMessage then "/conversations/#{conversation_id}"
    when Post then "/cohorts/#{cohort_id}/posts/#{id}"
    when PostComment then "/cohorts/#{post.cohort_id}/posts/#{post_id}"
    when GroupPost then "/groups/#{group_id}/group_posts/#{id}"
    when GroupPostComment then "/groups/#{group_post.group_id}/group_posts/#{group_post_id}"
    when FeedPost then "/feed/#{id}"
    when FeedPostComment then "/feed/#{feed_post_id}"
    end
  end

  def mention_notification_body
    case self
    when DirectMessage then "In a private message"
    when Post then "In a post in #{cohort.name}"
    when PostComment then "In a comment in #{post.cohort.name}"
    when GroupPost then "In a post in #{group.name}"
    when GroupPostComment then "In a comment in #{group_post.group.name}"
    when FeedPost then "In a feed post"
    when FeedPostComment then "In a comment on a feed post"
    end
  end
end
