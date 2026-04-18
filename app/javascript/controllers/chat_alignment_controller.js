import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { userId: Number }

  connect() {
    this.alignAll()
    this.observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType === Node.ELEMENT_NODE) this.align(node)
        }
      }
    })
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  alignAll() {
    this.element.querySelectorAll("[data-sender-id]").forEach((el) => this.align(el))
  }

  align(element) {
    const senderId = element.dataset.senderId
    if (!senderId) return
    if (Number(senderId) === this.userIdValue) {
      element.classList.add("flex-row-reverse")
    }
  }
}
