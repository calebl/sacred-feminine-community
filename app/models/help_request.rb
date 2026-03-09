class HelpRequest < ApplicationRecord
  belongs_to :user
  has_many :help_request_replies, dependent: :destroy

  enum :status, { open: 0, closed: 1 }

  validates :subject, presence: true
  validates :body, presence: true

  scope :newest_first, -> { order(created_at: :desc) }
  scope :needs_admin_attention, -> {
    open.where.not(
      id: HelpRequestReply.joins(:user).where(users: { role: :admin }).select(:help_request_id)
    )
  }
end
