import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]
  static values = {
    url: String,
    cohortId: String,
    groupId: String,
    conversationId: String
  }

  connect() {
    this.timeout = null
    this.mentioning = false
    this.mentionQuery = ""
    this.mentionStart = -1
  }

  onInput() {
    const input = this.inputTarget
    const value = input.value
    const cursorPos = input.selectionStart

    const textBeforeCursor = value.substring(0, cursorPos)
    const atIndex = textBeforeCursor.lastIndexOf("@")

    if (atIndex >= 0) {
      const charBefore = atIndex > 0 ? value[atIndex - 1] : " "
      if (charBefore === " " || charBefore === "\n" || atIndex === 0) {
        const query = textBeforeCursor.substring(atIndex + 1)
        if (!query.includes("[") && query.length > 0 && query.length <= 50) {
          this.mentioning = true
          this.mentionStart = atIndex
          this.mentionQuery = query
          this.search(query)
          return
        }
      }
    }

    this.closeMention()
  }

  search(query) {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", query)

    if (this.cohortIdValue) url.searchParams.set("cohort_id", this.cohortIdValue)
    if (this.groupIdValue) url.searchParams.set("group_id", this.groupIdValue)
    if (this.conversationIdValue) url.searchParams.set("conversation_id", this.conversationIdValue)

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/html",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']")?.content
        }
      })
      if (response.ok) {
        const html = await response.text()
        this.dropdownTarget.innerHTML = html
        this.dropdownTarget.classList.toggle("hidden", html.trim().length === 0)
      }
    } catch {
      this.closeMention()
    }
  }

  select(event) {
    event.preventDefault()
    const userId = event.params.userId
    const userName = event.params.userName

    const input = this.inputTarget
    const value = input.value

    const before = value.substring(0, this.mentionStart)
    const after = value.substring(this.mentionStart + 1 + this.mentionQuery.length)
    const mention = `@[${userName}](${userId}) `

    input.value = before + mention + after

    const newCursorPos = before.length + mention.length
    input.setSelectionRange(newCursorPos, newCursorPos)
    input.focus()

    this.closeMention()
  }

  closeMention() {
    this.mentioning = false
    this.mentionQuery = ""
    this.mentionStart = -1
    if (this.hasDropdownTarget) {
      this.dropdownTarget.innerHTML = ""
      this.dropdownTarget.classList.add("hidden")
    }
  }

  onKeydown(event) {
    if (event.key === "Escape" && this.mentioning) {
      event.preventDefault()
      this.closeMention()
    }
  }

  hide() {
    setTimeout(() => this.closeMention(), 200)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
