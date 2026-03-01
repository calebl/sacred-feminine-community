import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "message"]

  show(message) {
    this.messageTarget.textContent = message
    this.dialogTarget.showModal()

    requestAnimationFrame(() => {
      this.dialogTarget.dataset.open = ""
    })

    return new Promise((resolve) => {
      this.resolver = resolve
    })
  }

  confirm() {
    this.#close(true)
  }

  cancel() {
    this.#close(false)
  }

  backdropClick(event) {
    if (event.target === this.dialogTarget) {
      this.#close(false)
    }
  }

  handleCancel(event) {
    event.preventDefault()
    this.#close(false)
  }

  #close(result) {
    delete this.dialogTarget.dataset.open

    let cleaned = false
    const cleanup = () => {
      if (cleaned) return
      cleaned = true
      this.dialogTarget.close()
      if (this.resolver) {
        this.resolver(result)
        this.resolver = null
      }
    }

    this.dialogTarget.addEventListener("transitionend", cleanup, { once: true })
    setTimeout(cleanup, 300)
  }
}
