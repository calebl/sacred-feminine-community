import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, confirm: String }

  async copy() {
    if (this.hasConfirmValue) {
      const el = document.getElementById("confirm-dialog")
      const controller = el && window.Stimulus.getControllerForElementAndIdentifier(el, "confirm-dialog")
      const confirmed = controller ? await controller.show(this.confirmValue) : window.confirm(this.confirmValue)
      if (!confirmed) return
    }

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        }
      })

      if (!response.ok) throw new Error("Request failed")

      const { url } = await response.json()
      await navigator.clipboard.writeText(url)

      const button = this.element
      const original = button.textContent
      button.textContent = "Copied!"
      setTimeout(() => { button.textContent = original }, 2000)
    } catch {
      alert("Failed to copy invite link.")
    }
  }
}
