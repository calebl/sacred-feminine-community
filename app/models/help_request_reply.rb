class HelpRequestReply < ApplicationRecord
  belongs_to :help_request
  belongs_to :user

  validates :body, presence: true

  after_create :touch_help_request

  private

  def touch_help_request
    help_request.touch
  end
end
