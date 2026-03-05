import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  toggle() {
    this.formTarget.classList.toggle("hidden")

    if (!this.formTarget.classList.contains("hidden")) {
      this.formTarget.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }

  hide() {
    this.formTarget.classList.add("hidden")
  }
}
