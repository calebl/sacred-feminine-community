module PushNotifiable
  extend ActiveSupport::Concern

  private

  def push_notify(user_ids, title:, description:, path:)
    Array(user_ids).each do |uid|
      SendPushNotificationJob.perform_later(uid, title, description, path)
    end
  end
end
