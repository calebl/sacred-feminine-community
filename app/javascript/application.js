// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Register service worker for PWA support
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker.js")
}

import "trix"
import "@rails/actiontext"

// Custom Turbo Stream action: fade an element out, then remove it
Turbo.StreamActions.remove_with_fade = function () {
  this.targetElements.forEach((element) => {
    element.classList.add("opacity-0")
    setTimeout(() => element.remove(), 300)
  })
}

// Override Turbo's default browser confirm() with custom dialog
Turbo.setConfirmMethod((message) => {
  const el = document.getElementById("confirm-dialog")
  if (!el) return Promise.resolve(confirm(message))

  const controller = window.Stimulus.getControllerForElementAndIdentifier(el, "confirm-dialog")
  if (!controller) return Promise.resolve(confirm(message))

  return controller.show(message)
})
