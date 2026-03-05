import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "chips", "hiddenInputs", "body", "submit"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.selectedUsers = []
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

    if (this.selectedUsers.some(u => u.id === userId)) return

    this.selectedUsers.push({ id: userId, name: userName })

    this.renderChips()
    this.renderHiddenInputs()
    this.updateSubmitState()

    this.inputTarget.value = ""
    const frame = document.getElementById("member_search_results")
    if (frame) frame.innerHTML = ""

    this.inputTarget.focus()
  }

  deselect(event) {
    const userId = event.currentTarget.dataset.userId
    this.selectedUsers = this.selectedUsers.filter(u => u.id !== userId)

    this.renderChips()
    this.renderHiddenInputs()
    this.updateSubmitState()

    this.inputTarget.focus()
  }

  renderChips() {
    if (!this.hasChipsTarget) return

    this.chipsTarget.innerHTML = this.selectedUsers.map(user => `
      <span class="inline-flex items-center gap-2 bg-sf-gold/10 text-sf-gold text-sm font-semibold px-3 py-1.5 rounded-full">
        ${this.escapeHtml(user.name)}
        <button type="button" data-action="conversation-search#deselect" data-user-id="${user.id}" class="hover:text-sf-gold/70 transition">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
        </button>
      </span>
    `).join("")
  }

  renderHiddenInputs() {
    if (!this.hasHiddenInputsTarget) return

    this.hiddenInputsTarget.innerHTML = this.selectedUsers.map(user =>
      `<input type="hidden" name="recipient_ids[]" value="${user.id}">`
    ).join("")
  }

  hide() {
    setTimeout(() => {
      const frame = document.getElementById("member_search_results")
      if (frame) frame.innerHTML = ""
    }, 200)
  }

  updateSubmitState() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = this.selectedUsers.length === 0
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
