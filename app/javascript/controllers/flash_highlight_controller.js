import { Controller } from "@hotwired/stimulus"

// Draws attention to a freshly inserted element by flashing highlight classes
// on and off a few times. The element's own CSS transition fades each flash.
export default class extends Controller {
  static classes = ["highlight"]
  static values = {
    delay: { type: Number, default: 300 },    // wait before the first flash
    duration: { type: Number, default: 600 }, // how long each flash stays on
    gap: { type: Number, default: 300 },      // pause between flashes
    count: { type: Number, default: 2 }       // number of flashes
  }

  connect() {
    this.timeouts = []
    let at = this.delayValue
    for (let i = 0; i < this.countValue; i++) {
      this.schedule(() => this.element.classList.add(...this.highlightClasses), at)
      at += this.durationValue
      this.schedule(() => this.element.classList.remove(...this.highlightClasses), at)
      at += this.gapValue
    }
  }

  disconnect() {
    this.timeouts.forEach(clearTimeout)
  }

  schedule(fn, delay) {
    this.timeouts.push(setTimeout(fn, delay))
  }
}
