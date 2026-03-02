import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  async copyLink() {
    const formData = new FormData(this.formTarget)
    formData.append("delivery_method", "link")

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: formData
      })

      const data = await response.json()

      if (!response.ok) {
        alert(data.errors?.join("\n") || "Failed to create invitation.")
        return
      }

      await navigator.clipboard.writeText(data.url)
      window.location.href = this.formTarget.dataset.dashboardUrl
    } catch {
      alert("Failed to copy invite link.")
    }
  }
}
