import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content"]

  connect() {
    this.update()
  }

  update() {
    this.contentTarget.hidden = !this.triggerTarget.checked
  }
}
