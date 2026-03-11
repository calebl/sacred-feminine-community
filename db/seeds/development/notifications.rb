all_users = User.all.to_a
notification_base_time = 2.days.ago

all_users.each do |user|
  others = all_users.reject { |u| u.id == user.id }

  # Unread: mention notification
  user.notifications.create!(
    actor: others.sample,
    event_type: "mention",
    title: "#{others.sample.name} mentioned you",
    body: "In a post in #{Cohort.order('RANDOM()').first&.name || 'a cohort'}",
    path: "/cohorts/#{Cohort.first&.id}/posts/#{Post.first&.id}",
    notifiable_type: "Post",
    notifiable_id: Post.first&.id,
    created_at: notification_base_time + 1.hour
  )

  # Unread: direct message notification
  user.notifications.create!(
    actor: others.sample,
    event_type: "direct_message",
    title: others.sample.name,
    body: "Sent you a private message",
    path: "/conversations/#{Conversation.first&.id}",
    group_key: "conversation:#{Conversation.first&.id}",
    created_at: notification_base_time + 3.hours
  )

  # Unread: new comment notification
  user.notifications.create!(
    actor: others.sample,
    event_type: "new_comment",
    title: others.sample.name,
    body: "Commented on a feed post",
    path: "/feed/#{FeedPost.first&.id}",
    notifiable_type: "FeedPost",
    notifiable_id: FeedPost.first&.id,
    group_key: "feed_post_comments:#{FeedPost.first&.id}",
    created_at: notification_base_time + 5.hours
  )

  # Read: mention notification
  user.notifications.create!(
    actor: others.sample,
    event_type: "mention",
    title: "#{others.sample.name} mentioned you",
    body: "In a comment in #{Group.order('RANDOM()').first&.name || 'a group'}",
    path: "/groups/#{Group.first&.id}/group_posts/#{GroupPost.first&.id}",
    notifiable_type: "GroupPostComment",
    notifiable_id: GroupPostComment.first&.id,
    read_at: notification_base_time + 2.hours,
    created_at: notification_base_time
  )

  # Read: new member notification
  user.notifications.create!(
    actor: others.sample,
    event_type: "new_member",
    title: "New Member",
    body: "#{others.sample.name} has joined the community",
    path: "/admin/dashboard",
    read_at: notification_base_time + 4.hours,
    created_at: notification_base_time + 2.hours
  )
end

puts "Seeded notifications for #{all_users.size} users (3 unread, 2 read each)"
