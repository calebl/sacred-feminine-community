import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden", "dropdown"]
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
    this.mentionNode = null
    this.mentionOffset = -1

    const form = this.inputTarget.closest("form")
    if (form) {
      this.boundSync = () => this.syncHidden()
      this.boundReset = () => this.resetInput()
      form.addEventListener("submit", this.boundSync)
      form.addEventListener("turbo:submit-start", this.boundSync)
      form.addEventListener("turbo:submit-end", this.boundReset)
      form.addEventListener("reset", this.boundReset)
    }
  }

  onInput() {
    this.syncHidden()

    const sel = window.getSelection()
    if (!sel.rangeCount) return

    const range = sel.getRangeAt(0)
    const node = range.startContainer
    if (node.nodeType !== Node.TEXT_NODE) {
      this.closeMention()
      return
    }

    const text = node.textContent
    const cursorOffset = range.startOffset
    const textBeforeCursor = text.substring(0, cursorOffset)
    const atIndex = textBeforeCursor.lastIndexOf("@")

    if (atIndex >= 0) {
      const charBefore = atIndex > 0 ? text[atIndex - 1] : " "
      if (charBefore === " " || charBefore === "\n" || atIndex === 0) {
        const query = textBeforeCursor.substring(atIndex + 1)
        if (query.length > 0 && query.length <= 50) {
          this.mentioning = true
          this.mentionNode = node
          this.mentionOffset = atIndex
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

    if (!this.mentionNode || !this.mentionNode.parentNode) {
      this.closeMention()
      return
    }

    const text = this.mentionNode.textContent
    const before = text.substring(0, this.mentionOffset)
    const after = text.substring(this.mentionOffset + 1 + this.mentionQuery.length)

    const span = document.createElement("span")
    span.className = "mention-tag"
    span.contentEditable = "false"
    span.dataset.userId = userId
    span.dataset.userName = userName
    span.textContent = `@${userName}`

    const parent = this.mentionNode.parentNode
    const beforeNode = document.createTextNode(before)
    const afterNode = document.createTextNode(after.length > 0 ? after : "\u00A0")

    parent.insertBefore(beforeNode, this.mentionNode)
    parent.insertBefore(span, this.mentionNode)
    parent.insertBefore(afterNode, this.mentionNode)
    parent.removeChild(this.mentionNode)

    const range = document.createRange()
    range.setStart(afterNode, afterNode.textContent === "\u00A0" ? 1 : 0)
    range.collapse(true)
    const sel = window.getSelection()
    sel.removeAllRanges()
    sel.addRange(range)

    this.syncHidden()
    this.closeMention()
    this.inputTarget.focus()
  }

  syncHidden() {
    if (!this.hasHiddenTarget) return
    this.hiddenTarget.value = this.serialize()
  }

  serialize() {
    let result = ""
    const walk = (node) => {
      if (node.nodeType === Node.TEXT_NODE) {
        result += node.textContent
      } else if (node.nodeName === "BR") {
        result += "\n"
      } else if (node.classList?.contains("mention-tag")) {
        result += `@[${node.dataset.userName}](${node.dataset.userId})`
      } else {
        if (node !== this.inputTarget && (node.nodeName === "DIV" || node.nodeName === "P")) {
          result += "\n"
        }
        node.childNodes.forEach(child => walk(child))
      }
    }
    walk(this.inputTarget)
    return result.trim()
  }

  resetInput() {
    this.inputTarget.innerHTML = ""
    if (this.hasHiddenTarget) this.hiddenTarget.value = ""
  }

  onKeydown(event) {
    if (event.key === "Escape" && this.mentioning) {
      event.preventDefault()
      this.closeMention()
    }
    if (event.key === "Enter" && !event.shiftKey && this.inputTarget.dataset.singleLine !== undefined) {
      event.preventDefault()
      this.syncHidden()
      if (this.serialize().trim().length === 0) return
      const form = this.inputTarget.closest("form")
      if (form) form.requestSubmit()
    }
  }

  onPaste(event) {
    event.preventDefault()
    const text = event.clipboardData.getData("text/plain")
    document.execCommand("insertText", false, text)
    this.syncHidden()
  }

  closeMention() {
    this.mentioning = false
    this.mentionQuery = ""
    this.mentionNode = null
    this.mentionOffset = -1
    if (this.hasDropdownTarget) {
      this.dropdownTarget.innerHTML = ""
      this.dropdownTarget.classList.add("hidden")
    }
  }

  hide() {
    setTimeout(() => this.closeMention(), 200)
  }

  disconnect() {
    clearTimeout(this.timeout)
    const form = this.inputTarget?.closest("form")
    if (form) {
      form.removeEventListener("submit", this.boundSync)
      form.removeEventListener("turbo:submit-start", this.boundSync)
      form.removeEventListener("turbo:submit-end", this.boundReset)
      form.removeEventListener("reset", this.boundReset)
    }
  }
}
