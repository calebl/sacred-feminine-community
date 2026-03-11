import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  open(event) {
    event.preventDefault()
    const src = event.currentTarget.dataset.lightboxSrcValue
    this.imageTarget.src = src
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close(event) {
    if (event.target === this.modalTarget || event.currentTarget !== this.modalTarget) {
      this.modalTarget.classList.add("hidden")
      this.imageTarget.src = ""
      document.body.classList.remove("overflow-hidden")
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && !this.modalTarget.classList.contains("hidden")) {
      this.close(event)
    }
  }
}
