import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "preview", "customBody", "defaultBody"]

  connect() {
    this.update()
  }

  update() {
    const message = this.messageTarget.value.trim()
    if (message) {
      this.customBodyTarget.textContent = message
      this.customBodyTarget.classList.remove("hidden")
      this.defaultBodyTarget.classList.add("hidden")
    } else {
      this.customBodyTarget.classList.add("hidden")
      this.defaultBodyTarget.classList.remove("hidden")
    }
  }
}
