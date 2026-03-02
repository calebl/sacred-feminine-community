class ApplicationMailer < ActionMailer::Base
  default from: "community@#{ENV.fetch("APP_HOST", "example.com")}"
  layout "mailer"
end
