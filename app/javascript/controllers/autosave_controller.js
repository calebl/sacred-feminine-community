import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status"]
  static values = { url: String, interval: { type: Number, default: 5000 } }

  connect() {
    this.lastData = this.currentFormData()
    this.timer = setInterval(() => this.save(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
    this.save()
  }

  currentFormData() {
    const form = this.formTarget
    const data = new FormData(form)
    return new URLSearchParams(data).toString()
  }

  async save() {
    const currentData = this.currentFormData()
    if (currentData === this.lastData) return

    this.lastData = currentData
    this.statusTarget.textContent = "Saving..."

    try {
      const form = this.formTarget
      const token = document.querySelector('meta[name="csrf-token"]')?.content

      await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": token
        },
        body: new FormData(form)
      })

      this.statusTarget.textContent = "Draft saved"
    } catch {
      this.statusTarget.textContent = "Save failed"
    }
  }
}
