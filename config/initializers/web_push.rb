# VAPID keys for Web Push notifications.
#
# Generate a new key pair with:
#   bin/rails runner "keys = WebPush.generate_key; puts keys.public_key; puts keys.private_key"
#
# Store them in Rails credentials:
#   bin/rails credentials:edit
#
#   vapid:
#     public_key: <public_key>
#     private_key: <private_key>
#
Rails.application.config.vapid = {
  subject: "mailto:#{ENV.fetch('VAPID_SUBJECT', 'admin@sacredfeminine.community')}",
  public_key: Rails.application.credentials.dig(:vapid, :public_key) || ENV["VAPID_PUBLIC_KEY"],
  private_key: Rails.application.credentials.dig(:vapid, :private_key) || ENV["VAPID_PRIVATE_KEY"]
}
