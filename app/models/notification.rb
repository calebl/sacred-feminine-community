class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(30) }

  validates :title, presence: true
  validates :event_type, presence: true,
    inclusion: { in: %w[mention direct_message new_comment new_member help_request help_request_reply] }

  def read?
    read_at.present?
  end
end
