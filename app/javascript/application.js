// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "trix"
import "@rails/actiontext"

// Override Turbo's default browser confirm() with custom dialog
Turbo.setConfirmMethod((message) => {
  const el = document.getElementById("confirm-dialog")
  if (!el) return Promise.resolve(confirm(message))

  const controller = window.Stimulus.getControllerForElementAndIdentifier(el, "confirm-dialog")
  if (!controller) return Promise.resolve(confirm(message))

  return controller.show(message)
})
