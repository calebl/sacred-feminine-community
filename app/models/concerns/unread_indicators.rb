# Query API powering the per-context unread "gold dots" (top-bar Messages link,
# sidebar cohorts/groups). All reads derive from a single memoized query so the
# sidebar and the per-post observers share one trip to the database per request
# (current_user is one instance per request).
module UnreadIndicators
  extend ActiveSupport::Concern

  def unread_notification_rows
    @unread_notification_rows ||=
      notifications.unread.pluck(:event_type, :notifiable_type, :notifiable_id)
  end

  def unread_messages?
    unread_notification_rows.any? { |_event, type, _id| type == "DirectMessage" }
  end

  # Cohort ids with unread activity: new posts/mentions on a Post, grouped
  # new_comment rows (notifiable = Post), and mentions on a PostComment.
  def unread_cohort_ids
    @unread_cohort_ids ||= begin
      post_ids = unread_notifiable_ids("Post")
      comment_ids = unread_notifiable_ids("PostComment")
      ids = Post.where(id: post_ids).distinct.pluck(:cohort_id)
      ids += PostComment.where(id: comment_ids).joins(:post).distinct.pluck("posts.cohort_id")
      ids.to_set
    end
  end

  # Group ids with unread activity: new posts/comments/mentions mapped to their
  # group. new_member notifications deliberately do not light the dot.
  def unread_group_ids
    @unread_group_ids ||= begin
      post_ids = unread_notifiable_ids("GroupPost")
      comment_ids = unread_notifiable_ids("GroupPostComment")
      ids = GroupPost.where(id: post_ids).distinct.pluck(:group_id)
      ids += GroupPostComment.where(id: comment_ids).joins(:group_post).distinct.pluck("group_posts.group_id")
      ids.to_set
    end
  end

  # Per-record predicates used to decide whether to attach the scroll-into-view
  # observer (so we never fire requests for already-read items).
  def unread_for_post?(post)
    unread_notification_rows.any? do |event, type, id|
      type == "Post" && id == post.id && %w[new_post mention].include?(event)
    end
  end

  def unread_for_post_comment?(comment)
    unread_notification_rows.any? do |event, type, id|
      (type == "PostComment" && id == comment.id && event == "mention") ||
        (type == "Post" && id == comment.post_id && event == "new_comment")
    end
  end

  def unread_for_group_post?(group_post)
    unread_notification_rows.any? do |event, type, id|
      type == "GroupPost" && id == group_post.id && %w[new_post mention].include?(event)
    end
  end

  def unread_for_group_post_comment?(comment)
    unread_notification_rows.any? do |event, type, id|
      (type == "GroupPostComment" && id == comment.id && event == "mention") ||
        (type == "GroupPost" && id == comment.group_post_id && event == "new_comment")
    end
  end

  private

  def unread_notifiable_ids(notifiable_type)
    unread_notification_rows.filter_map { |_event, type, id| id if type == notifiable_type }.uniq
  end
end
