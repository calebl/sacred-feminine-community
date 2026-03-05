import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "selected", "selectedName", "searchWrapper", "recipientId", "body", "submit"]
  static values = { url: String }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 300)
  }

  performSearch() {
    const query = this.inputTarget.value.trim()
    const frame = document.getElementById("member_search_results")
    if (!frame) return

    if (query.length === 0) {
      frame.innerHTML = ""
      return
    }

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", query)

    frame.src = url.toString()
  }

  select(event) {
    event.preventDefault()
    const button = event.currentTarget
    const userId = button.dataset.userId
    const userName = button.dataset.userName

    if (this.hasRecipientIdTarget) {
      this.recipientIdTarget.value = userId
    }

    if (this.hasSelectedNameTarget) {
      this.selectedNameTarget.textContent = userName
    }

    if (this.hasSelectedTarget) {
      this.selectedTarget.classList.remove("hidden")
    }

    if (this.hasSearchWrapperTarget) {
      this.searchWrapperTarget.classList.add("hidden")
    }

    this.inputTarget.value = ""
    const frame = document.getElementById("member_search_results")
    if (frame) frame.innerHTML = ""

    this.updateSubmitState()

    if (this.hasBodyTarget) {
      this.bodyTarget.focus()
    }
  }

  deselect() {
    if (this.hasRecipientIdTarget) {
      this.recipientIdTarget.value = ""
    }

    if (this.hasSelectedTarget) {
      this.selectedTarget.classList.add("hidden")
    }

    if (this.hasSearchWrapperTarget) {
      this.searchWrapperTarget.classList.remove("hidden")
    }

    this.updateSubmitState()
    this.inputTarget.focus()
  }

  hide() {
    setTimeout(() => {
      const frame = document.getElementById("member_search_results")
      if (frame) frame.innerHTML = ""
    }, 200)
  }

  updateSubmitState() {
    if (this.hasSubmitTarget && this.hasRecipientIdTarget) {
      this.submitTarget.disabled = !this.recipientIdTarget.value
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
