module PushNotifiable
  extend ActiveSupport::Concern

  private

  def push_notify(user_ids, title:, path:)
    Array(user_ids).each do |uid|
      SendPushNotificationJob.perform_later(uid, title, body.truncate(100), path)
    end
  end
end
