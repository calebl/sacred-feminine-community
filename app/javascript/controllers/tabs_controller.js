import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { activeTab: { type: String, default: "chat" } }

  connect() {
    this.activate(this.activeTabValue)
  }

  select(event) {
    const name = event.currentTarget.dataset.tabName
    this.activate(name)
    this.updateUrl(name)
  }

  activate(name) {
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.tabName === name
      tab.classList.toggle("border-sf-gold", isActive)
      tab.classList.toggle("text-sf-gold", isActive)
      tab.classList.toggle("border-transparent", !isActive)
      tab.classList.toggle("text-gray-400", !isActive)
    })

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.panelName !== name)
    })
  }

  updateUrl(name) {
    const url = new URL(window.location)
    url.searchParams.set("tab", name)
    history.replaceState(history.state, "", url)
  }
}
