import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "card", "empty"]

  connect() {
    const query = new URL(window.location).searchParams.get("q")
    if (query) {
      this.inputTarget.value = query
      this.filter()
    }
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    let visibleCount = 0

    this.cardTargets.forEach((card) => {
      const name = (card.dataset.name || "").toLowerCase()
      const location = (card.dataset.location || "").toLowerCase()
      const match = !query || name.includes(query) || location.includes(query)
      card.classList.toggle("hidden", !match)
      if (match) visibleCount++
    })

    this.emptyTarget.classList.toggle("hidden", visibleCount > 0)
    this.updateUrl(this.inputTarget.value.trim())
  }

  updateUrl(query) {
    const url = new URL(window.location)
    if (query) {
      url.searchParams.set("q", query)
    } else {
      url.searchParams.delete("q")
    }
    history.replaceState(history.state, "", url)
  }
}
