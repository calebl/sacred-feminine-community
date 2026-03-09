class HelpRequest < ApplicationRecord
  belongs_to :user
  has_many :help_request_replies, dependent: :destroy

  enum :status, { open: 0, closed: 1 }

  validates :subject, presence: true
  validates :body, presence: true

  after_create_commit :notify_admins

  scope :newest_first, -> { order(created_at: :desc) }
  scope :needs_admin_attention, -> {
    open.where.not(
      id: HelpRequestReply.joins(:user).where(users: { role: :admin }).select(:help_request_id)
    )
  }

  private

  def notify_admins
    User.admin.where.not(id: user_id).pluck(:id).each do |admin_id|
      CreateNotificationJob.perform_later(
        user_id: admin_id,
        actor_id: user_id,
        event_type: "help_request",
        title: "New Help Request",
        body: "#{user.name}: #{subject}",
        path: "/help_requests/#{id}",
        notifiable_type: "HelpRequest",
        notifiable_id: id
      )
    end
  end
end
