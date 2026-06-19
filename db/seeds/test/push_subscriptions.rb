push_subscriptions.create :admin_sub,
  user: users.admin,
  endpoint: "https://push.example.com/admin-device-1",
  p256dh_key: "BNcRdreALRFXTkOOUHK1EtK2wtaz5Ry4YfYCA_0QTpQtUbVlUls0VJXg7A8u-Ts1XbjhazAkj7I99e8p8REfines",
  auth_key: "tBHItJI5svbpC7EvGFDjQA"

push_subscriptions.create :attendee_sub,
  user: users.attendee,
  endpoint: "https://push.example.com/attendee-device-1",
  p256dh_key: "BNcRdreALRFXTkOOUHK1EtK2wtaz5Ry4YfYCA_0QTpQtUbVlUls0VJXg7A8u-Ts1XbjhazAkj7I99e8p8REfXYZ",
  auth_key: "uCIJtJI5svbpC7EvGFDjQB"
