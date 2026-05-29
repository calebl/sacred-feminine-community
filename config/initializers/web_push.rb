# VAPID keys for Web Push notifications.
#
# Once injects VAPID_PUBLIC_KEY and VAPID_PRIVATE_KEY env vars automatically.
# Alternatively, store them in Rails credentials:
#   bin/rails credentials:edit
#
#   vapid:
#     public_key: <public_key>
#     private_key: <private_key>
#
# Generate a new key pair with:
#   bin/rails runner "keys = WebPush.generate_key; puts keys.public_key; puts keys.private_key"
#
vapid_from_credentials = begin
  {
    subject: Rails.application.credentials.dig(:vapid, :subject),
    public_key: Rails.application.credentials.dig(:vapid, :public_key),
    private_key: Rails.application.credentials.dig(:vapid, :private_key)
  }
rescue ActiveSupport::MessageEncryptor::InvalidMessage
  { subject: nil, public_key: nil, private_key: nil }
end

Rails.application.config.vapid = {
  subject: "mailto:#{vapid_from_credentials[:subject] || "admin@sacredfeminine.community"}",
  public_key: ENV["VAPID_PUBLIC_KEY"] || vapid_from_credentials[:public_key],
  private_key: ENV["VAPID_PRIVATE_KEY"] || vapid_from_credentials[:private_key]
}
