import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { count: Number }

  connect() {
    this.updateBadge()
  }

  countValueChanged() {
    this.updateBadge()
  }

  async updateBadge() {
    if (!("setAppBadge" in navigator)) return
    try {
      if (this.countValue > 0) {
        await navigator.setAppBadge(this.countValue)
      } else {
        await navigator.clearAppBadge()
      }
    } catch (_) {}
  }
}
