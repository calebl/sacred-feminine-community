class ChatMessage < ApplicationRecord
  include Mentionable

  belongs_to :cohort
  belongs_to :user

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit -> {
    message = ChatMessage.includes(user: { avatar_attachment: :blob }).find(id)
    broadcast_append_to(
      cohort,
      :chat,
      target: "chat_messages",
      partial: "shared/chat_message",
      locals: { message: message }
    )
  }

  after_create_commit :send_push_notifications, unless: :system_message?

  private

  def send_push_notifications
    cohort.cohort_memberships.where.not(user_id: user_id).includes(:user).find_each do |membership|
      SendPushNotificationJob.perform_later(
        membership.user_id,
        "#{user.name} in #{cohort.name}",
        body.truncate(100),
        "/cohorts/#{cohort_id}"
      )
    end
  end
end
