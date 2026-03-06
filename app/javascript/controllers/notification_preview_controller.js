import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { name: String, avatarUrl: String, initial: String }

  preview() {
    const container = document.getElementById("dm_notifications")
    if (!container) return

    const el = document.createElement("div")
    el.className = "pointer-events-auto opacity-0 translate-y-2 transition-all duration-300 ease-out"
    el.setAttribute("data-dm-notification-target", "notification")
    el.setAttribute("data-conversation-id", "preview")
    el.setAttribute("data-url", "")
    el.innerHTML = `
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-lg border border-sf-sand/20 dark:border-gray-700 p-4 max-w-sm w-full mx-auto md:mx-0">
        <div class="flex items-start gap-3">
          <div class="flex-shrink-0 w-10 h-10 rounded-full bg-sf-sand/50 dark:bg-gray-700 flex items-center justify-center text-sm font-bold text-sf-black dark:text-white" data-role="avatar">
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-sf-black dark:text-white truncate" data-role="name"></p>
            <p class="text-sm text-gray-600 dark:text-gray-400 truncate">Hey! This is what a notification looks like.</p>
          </div>
          <button type="button" class="flex-shrink-0 p-1 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                  data-action="click->dm-notification#dismiss">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
      </div>
    `

    const avatarContainer = el.querySelector("[data-role='avatar']")
    if (this.hasAvatarUrlValue && this.avatarUrlValue) {
      const img = document.createElement("img")
      img.src = this.avatarUrlValue
      img.className = "w-10 h-10 rounded-full object-cover"
      avatarContainer.appendChild(img)
    } else {
      avatarContainer.textContent = this.initialValue
    }

    el.querySelector("[data-role='name']").textContent = this.nameValue

    container.appendChild(el)
  }
}
