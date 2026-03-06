import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker"]
  static values = {
    reactableType: String,
    reactableId: Number,
    url: String
  }

  toggle() {
    this.pickerTarget.classList.toggle("hidden")
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.pickerTarget.classList.add("hidden")
    }
  }

  async react(event) {
    const emoji = event.currentTarget.dataset.emoji
    this.pickerTarget.classList.add("hidden")

    const token = document.querySelector('meta[name="csrf-token"]').content
    const response = await fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({
        reactable_type: this.reactableTypeValue,
        reactable_id: this.reactableIdValue,
        emoji: emoji
      })
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    }
  }
}
