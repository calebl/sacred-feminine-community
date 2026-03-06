import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    this.observer = new MutationObserver(() => this.scrollToBottom())
    this.observer.observe(this.element, { childList: true })
    this.panelShownHandler = () => this.scrollToBottom()
    this.element.closest("[data-panel-name]")?.addEventListener("panel:shown", this.panelShownHandler)
  }

  disconnect() {
    this.observer.disconnect()
    this.element.closest("[data-panel-name]")?.removeEventListener("panel:shown", this.panelShownHandler)
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
