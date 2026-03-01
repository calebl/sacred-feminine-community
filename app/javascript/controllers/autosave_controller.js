import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status"]
  static values = { url: String, interval: { type: Number, default: 5000 } }

  connect() {
    this.lastData = this.currentFormData()
    this.dirty = false
    this.timer = setInterval(() => this.save(), this.intervalValue)
    this.formTarget.addEventListener("input", this.markDirty)
  }

  disconnect() {
    this.formTarget.removeEventListener("input", this.markDirty)
    clearInterval(this.timer)
    this.save()
  }

  markDirty = () => {
    if (!this.dirty) {
      this.dirty = true
      this.statusTarget.textContent = "Unsaved changes"
    }
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

      this.dirty = false
      const time = new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })
      this.statusTarget.textContent = `Draft saved at ${time}`
    } catch {
      this.statusTarget.textContent = "Save failed"
    }
  }
}
