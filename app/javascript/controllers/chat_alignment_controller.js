import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { userId: Number }

  connect() {
    this.alignMessages()
    this.observer = new MutationObserver(() => this.alignMessages())
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer.disconnect()
  }

  alignMessages() {
    this.element.querySelectorAll("[data-sender-id]").forEach((msg) => {
      if (msg.dataset.aligned) return

      const isOwn = parseInt(msg.dataset.senderId) === this.userIdValue

      if (isOwn) {
        msg.classList.add("flex-row-reverse")
        const bubble = msg.querySelector("[data-message-bubble]")
        if (bubble) {
          bubble.classList.remove("bg-sf-beige")
          bubble.classList.add("bg-sf-gold/20")
        }
        const name = msg.querySelector("[data-sender-name]")
        if (name) name.classList.add("hidden")
      }

      msg.dataset.aligned = "true"
    })
  }
}
