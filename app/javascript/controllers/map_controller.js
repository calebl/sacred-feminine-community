import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import "leaflet.markercluster"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.map = L.map(this.element).setView([30, 10], 2)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 18,
    }).addTo(this.map)

    this.loadPins()

    this.hasFittedBounds = false
    this.resizeObserver = new ResizeObserver(() => {
      if (!this.map) return
      this.map.invalidateSize()
      if (this.pinBounds && !this.hasFittedBounds) {
        this.map.fitBounds(this.pinBounds, { padding: [50, 50] })
        this.hasFittedBounds = true
      }
    })
    this.resizeObserver.observe(this.element)

    this.boundBeforeCache = this.beforeCache.bind(this)
    document.addEventListener("turbo:before-cache", this.boundBeforeCache)
  }

  beforeCache() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  async loadPins() {
    const response = await fetch(this.urlValue, {
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })
    const pins = await response.json()

    const markers = L.markerClusterGroup()

    pins.forEach(pin => {
      const marker = L.marker([pin.lat, pin.lng])

      const container = document.createElement("div")
      container.className = "text-center"

      const name = document.createElement("strong")
      name.textContent = pin.name
      container.appendChild(name)

      container.appendChild(document.createElement("br"))

      const location = document.createElement("span")
      location.className = "text-gray-500"
      location.textContent = [pin.city, pin.state, pin.country].filter(Boolean).join(", ")
      container.appendChild(location)

      container.appendChild(document.createElement("br"))

      const link = document.createElement("a")
      link.href = `/profiles/${encodeURIComponent(pin.id)}`
      link.className = "text-blue-600 text-sm"
      link.textContent = "View Profile"
      container.appendChild(link)

      marker.bindPopup(container)
      markers.addLayer(marker)
    })

    if (!this.map) return

    this.map.addLayer(markers)

    if (pins.length > 0) {
      this.pinBounds = L.latLngBounds(pins.map(p => [p.lat, p.lng]))
      if (this.element.offsetWidth > 0) {
        this.map.fitBounds(this.pinBounds, { padding: [50, 50] })
        this.hasFittedBounds = true
      }
    }
  }

  disconnect() {
    this.resizeObserver.disconnect()
    document.removeEventListener("turbo:before-cache", this.boundBeforeCache)
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }
}
