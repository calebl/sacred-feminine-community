import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker"]
  static values = {
    reactableType: String,
    reactableId: Number,
    url: String,
    currentId: { type: Number, default: 0 },
    currentEmoji: { type: String, default: "" }
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
    if (this.hasPickerTarget) this.pickerTarget.classList.add("hidden")

    const token = document.querySelector('meta[name="csrf-token"]').content
    let method, url, body

    if (this.currentIdValue > 0 && this.currentEmojiValue === emoji) {
      method = "DELETE"
      url = `${this.urlValue}/${this.currentIdValue}`
      body = null
    } else if (this.currentIdValue > 0) {
      method = "PATCH"
      url = `${this.urlValue}/${this.currentIdValue}`
      body = JSON.stringify({ emoji: emoji })
    } else {
      method = "POST"
      url = this.urlValue
      body = JSON.stringify({
        reactable_type: this.reactableTypeValue,
        reactable_id: this.reactableIdValue,
        emoji: emoji
      })
    }

    const response = await fetch(url, {
      method: method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: body
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    }
  }
}
