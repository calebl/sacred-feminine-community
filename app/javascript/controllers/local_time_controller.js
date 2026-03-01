import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const date = new Date(this.element.dateTime)
    this.element.textContent = date.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })
  }
}
