import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notification"]

  connect() {
    this.seenMessageIds = new Set()
  }

  notificationTargetConnected(el) {
    const messageId = el.dataset.messageId
    const conversationId = el.dataset.conversationId
    const currentConversationId = document.body.dataset.currentConversationId

    // Deduplicate: skip if we've already shown this message
    if (messageId && this.seenMessageIds.has(messageId)) {
      el.remove()
      return
    }

    // Suppress if user is already viewing this conversation
    if (currentConversationId && currentConversationId === conversationId) {
      el.remove()
      return
    }

    if (messageId) this.seenMessageIds.add(messageId)

    // Animate in
    requestAnimationFrame(() => {
      el.classList.remove("opacity-0", "translate-y-2")
      el.classList.add("opacity-100", "translate-y-0")
    })

    // Auto-dismiss after 6 seconds
    el._dismissTimer = setTimeout(() => this.animateOut(el), 6000)
  }

  dismiss(event) {
    event.stopPropagation()
    const el = event.target.closest("[data-dm-notification-target='notification']")
    if (el) {
      clearTimeout(el._dismissTimer)
      this.animateOut(el)
    }
  }

  navigate(event) {
    const el = event.target.closest("[data-dm-notification-target='notification']")
    if (el) {
      clearTimeout(el._dismissTimer)
      const url = el.dataset.url
      if (url) {
        window.Turbo.visit(url)
      }
      this.animateOut(el)
    }
  }

  animateOut(el) {
    el.classList.remove("opacity-100", "translate-y-0")
    el.classList.add("opacity-0", "-translate-y-2")
    el.addEventListener("transitionend", () => el.remove(), { once: true })
    // Fallback removal if transitionend doesn't fire
    setTimeout(() => { if (el.parentNode) el.remove() }, 400)
  }
}
