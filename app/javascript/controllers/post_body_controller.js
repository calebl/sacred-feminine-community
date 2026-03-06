import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggle"]

  connect() {
    requestAnimationFrame(() => this.checkTruncation())
  }

  checkTruncation() {
    const el = this.contentTarget
    if (el.scrollHeight > el.clientHeight) {
      this.toggleTarget.classList.remove("hidden")
    }
  }

  toggle() {
    const el = this.contentTarget
    if (el.classList.contains("line-clamp-[15]")) {
      el.classList.remove("line-clamp-[15]")
      this.toggleTarget.textContent = "show less"
    } else {
      el.classList.add("line-clamp-[15]")
      this.toggleTarget.textContent = "view more"
    }
  }
}
