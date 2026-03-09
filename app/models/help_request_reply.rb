class HelpRequestReply < ApplicationRecord
  belongs_to :help_request, counter_cache: true
  belongs_to :user

  validates :body, presence: true

  after_create_commit :touch_help_request
  after_create_commit :notify_participants

  private

  def touch_help_request
    help_request.touch
  end

  def notify_participants
    recipient_ids = if user.admin?
      [ help_request.user_id ]
    else
      help_request.help_request_replies
        .joins(:user).where(users: { role: :admin })
        .where.not(user_id: user_id)
        .distinct.pluck(:user_id)
    end

    recipient_ids.each do |rid|
      CreateNotificationJob.perform_later(
        user_id: rid,
        actor_id: user_id,
        event_type: "help_request_reply",
        title: "Help Request Reply",
        body: "#{user.name} replied to: #{help_request.subject}",
        path: "/help_requests/#{help_request_id}",
        notifiable_type: "HelpRequest",
        notifiable_id: help_request_id
      )
    end
  end
end
