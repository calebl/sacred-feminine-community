import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["replies"]

  toggle() {
    this.repliesTarget.classList.toggle("hidden")
  }
}
