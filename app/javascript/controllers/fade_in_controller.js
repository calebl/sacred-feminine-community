import { Controller } from "@hotwired/stimulus"

// Fades its element into place on connect by dropping an initial opacity-0 class.
export default class extends Controller {
  connect() {
    requestAnimationFrame(() => this.element.classList.remove("opacity-0"))
  }
}
