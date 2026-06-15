import { Controller } from "@hotwired/stimulus"

// Marks a post/comment's notifications as read once it actually scrolls into
// view. Collapsed (display:none) comments never intersect, so they are only
// marked once expanded and seen. Fires once, then stops observing.
export default class extends Controller {
  static values = {
    type: String,
    id: Number,
    url: String,
    threshold: { type: Number, default: 0.6 }
  }

  connect() {
    this.seen = false
    this.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          // The initial callback can fire with isIntersecting=true while only a
          // sliver is on screen, so require the configured visible ratio too.
          if (entry.isIntersecting && entry.intersectionRatio >= this.thresholdValue) {
            this.markSeen()
          }
        }
      },
      { threshold: this.thresholdValue }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  async markSeen() {
    if (this.seen) return
    this.seen = true
    this.observer.disconnect()

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token,
          "Accept": "application/json"
        },
        body: JSON.stringify({ type: this.typeValue, id: this.idValue })
      })
    } catch (_e) {
      // Best-effort; the dot will reconcile on the next page load.
      this.seen = false
    }
  }
}
