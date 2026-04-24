import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "preview", "body"]

  connect() {
    this.update()
  }

  update() {
    this.bodyTarget.textContent = this.messageTarget.value.trim()
  }
}
