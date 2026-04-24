import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = { message: String, type: String }

  connect() {
    if (this.hasMessageValue && this.messageValue) {
      this.show(this.messageValue, this.typeValue)
    }
  }

  show(message, type = "notice") {
    const toast = document.createElement("div")
    const icon = type === "alert"
      ? `<svg class="w-5 h-5 text-sf-red flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`
      : `<svg class="w-5 h-5 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`

    toast.className = `flex items-center gap-3 px-4 py-3 bg-white dark:bg-gray-800 rounded-xl shadow-lg border border-sf-sand/20 dark:border-gray-700 pointer-events-auto transform transition-all duration-300 translate-y-2 opacity-0`
    toast.innerHTML = `${icon}<p class="text-sm text-sf-black dark:text-white flex-1">${message}</p><button type="button" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 flex-shrink-0" data-action="click->flash#dismiss"><svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg></button>`

    this.containerTarget.appendChild(toast)

    requestAnimationFrame(() => {
      toast.classList.remove("translate-y-2", "opacity-0")
    })

    setTimeout(() => this.remove(toast), 5000)
  }

  dismiss(event) {
    this.remove(event.target.closest("[data-action]"))
  }

  remove(toast) {
    if (!toast || !toast.parentNode) return
    toast.classList.add("translate-y-2", "opacity-0")
    setTimeout(() => toast.remove(), 300)
  }
}
